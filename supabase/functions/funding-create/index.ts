import { createClient } from "npm:@supabase/supabase-js@2";
import { adminClient } from "../_shared/ledger/account_ledger_service.ts";
import { createPaymentRequest, withRedirect } from "../_shared/stitch/stitch_client.ts";
import { DEPOSIT_LIMITS, stitchConfig } from "../_shared/stitch/stitch_config.ts";

const json = (b: unknown, status = 200) =>
  new Response(JSON.stringify(b), { status, headers: { "Content-Type": "application/json" } });

Deno.serve(async (req) => {
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  // 1. Authenticate the customer
  const userClient = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data: { user } } = await userClient.auth.getUser();
  if (!user) return json({ error: "unauthorized" }, 401);

  // 2. Validate input (server decides everything that matters)
  const body = await req.json().catch(() => ({}));
  const amountCents = body.amount_cents;
  if (!Number.isInteger(amountCents) || amountCents < DEPOSIT_LIMITS.minCents || amountCents > DEPOSIT_LIMITS.maxCents) {
    return json({ error: "invalid_amount", min_cents: DEPOSIT_LIMITS.minCents, max_cents: DEPOSIT_LIMITS.maxCents }, 400);
  }
  const idempotencyKey: string | null = req.headers.get("Idempotency-Key");

  const db = adminClient();

  // 3. Replay protection
  if (idempotencyKey) {
    const { data: existing } = await db.from("deposit_intents").select("*")
      .eq("user_id", user.id).eq("idempotency_key", idempotencyKey).maybeSingle();
    if (existing) {
      return json({ intent_id: existing.id, status: existing.status, payment_url: existing.payment_url, reference: existing.reference });
    }
  }

  // 4. Resolve the ZAR account (accounts_user_id_idx => one account per user)
  const { data: account } = await db.from("accounts")
    .select("id, status, currency, full_name").eq("user_id", user.id).maybeSingle();
  if (!account || account.status !== "active" || account.currency !== "ZAR") {
    return json({ error: "account_not_available" }, 409);
  }

  // 5. Record intent, then call Stitch
  const reference = "KLIPA" + crypto.randomUUID().replace(/-/g, "").slice(0, 6).toUpperCase(); // 11 chars
  const { data: intent, error: insErr } = await db.from("deposit_intents").insert({
    user_id: user.id, account_id: account.id, amount_cents: amountCents,
    reference, idempotency_key: idempotencyKey,
  }).select().single();
  if (insErr) return json({ error: "intent_create_failed" }, 500);

  try {
    const pr = await createPaymentRequest({
      amountCents,
      externalReference: intent.id,
      payerReference: reference,
      beneficiaryReference: reference,
      expireAt: new Date(Date.now() + DEPOSIT_LIMITS.expiryMinutes * 60_000).toISOString(),
      payer: { identifier: user.id, fullName: account.full_name ?? undefined, email: user.email ?? undefined },
    });
    const url = withRedirect(pr.interaction!.url, stitchConfig().redirectUri);
    await db.from("deposit_intents")
      .update({ provider_payment_id: pr.id, payment_url: url, status: "pending", last_provider_status: pr.status })
      .eq("id", intent.id);
    return json({ intent_id: intent.id, status: "pending", payment_url: url, reference });
  } catch (e) {
    console.error("deposit-create failed", e);
    await db.from("deposit_intents")
      .update({ status: "failed", failure_reason: "provider_create_failed" }).eq("id", intent.id);
    return json({ error: "provider_unavailable" }, 502);
  }
});