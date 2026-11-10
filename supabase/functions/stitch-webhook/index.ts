import { Webhook } from "npm:svix@1.45.1";
import { adminClient, reconcileIntent } from "../_shared/ledger/account_ledger_service.ts";
import { stitchConfig } from "../_shared/stitch/stitch_config.ts";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Payload shape isn't relied on: we only extract candidate ids, then ask Stitch for the truth.
// deno-lint-ignore no-explicit-any
function candidates(p: any): string[] {
  const d = p?.data ?? {};
  return [d.id, d.paymentRequestId, d.paymentRequest?.id, d.externalReference, p?.externalReference, p?.id]
    .filter((x): x is string => typeof x === "string");
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("method_not_allowed", { status: 405 });

  const raw = await req.text(); // raw body required for signature check
  const id = req.headers.get("svix-id"), ts = req.headers.get("svix-timestamp"), sig = req.headers.get("svix-signature");
  if (!id || !ts || !sig) return new Response("missing_headers", { status: 400 });

  // deno-lint-ignore no-explicit-any
  let payload: any;
  try {
    payload = new Webhook(stitchConfig().webhookSecret)
      .verify(raw, { "svix-id": id, "svix-timestamp": ts, "svix-signature": sig });
  } catch {
    return new Response("invalid_signature", { status: 400 });
  }

  const db = adminClient();

  // Idempotency: svix-id is stable across retries
  await db.from("provider_webhook_events").upsert(
    { provider: "stitch", event_id: id, event_type: payload?.type ?? null, payload },
    { onConflict: "provider,event_id", ignoreDuplicates: true },
  );
  const { data: ev } = await db.from("provider_webhook_events").select("id, processed_at")
    .eq("provider", "stitch").eq("event_id", id).single();
  if (ev?.processed_at) return new Response("ok", { status: 200 });

  try {
    const ids = candidates(payload);
    const uuids = ids.filter((x) => UUID.test(x));
    const filters = [`provider_payment_id.in.(${ids.map((x) => `"${x}"`).join(",")})`];
    if (uuids.length) filters.push(`id.in.(${uuids.join(",")})`);
    const { data: intent } = await db.from("deposit_intents").select("*").or(filters.join(",")).maybeSingle();

    if (intent) await reconcileIntent(db, intent);
    else console.warn("stitch-webhook: no matching deposit intent", { event: payload?.type, ids });

    await db.from("provider_webhook_events").update({ processed_at: new Date().toISOString() }).eq("id", ev!.id);
    return new Response("ok", { status: 200 });
  } catch (e) {
    console.error("stitch-webhook failed", e);
    await db.from("provider_webhook_events").update({ error: String(e) }).eq("id", ev!.id);
    return new Response("retry", { status: 500 }); // Svix will retry
  }
});