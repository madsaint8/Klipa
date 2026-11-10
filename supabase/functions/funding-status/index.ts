import { createClient } from "npm:@supabase/supabase-js@2";
import { adminClient, reconcileIntent } from "../_shared/ledger/account_ledger_service.ts";

const json = (b: unknown, status = 200) =>
  new Response(JSON.stringify(b), { status, headers: { "Content-Type": "application/json" } });

// GET/POST ?intent_id=...  Fallback for when the app returns before the webhook lands.
Deno.serve(async (req) => {
  const userClient = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: req.headers.get("Authorization") ?? "" } },
  });
  const { data: { user } } = await userClient.auth.getUser();
  if (!user) return json({ error: "unauthorized" }, 401);

  const intentId = new URL(req.url).searchParams.get("intent_id") ?? (await req.json().catch(() => ({}))).intent_id;
  if (!intentId) return json({ error: "intent_id_required" }, 400);

  const db = adminClient();
  const { data: intent } = await db.from("deposit_intents").select("*")
    .eq("id", intentId).eq("user_id", user.id).maybeSingle();
  if (!intent) return json({ error: "not_found" }, 404);

  let status = intent.status;
  if (["created", "pending"].includes(status)) {
    try { status = (await reconcileIntent(db, intent)).status; }
    catch (e) { console.error("status reconcile failed", e); }
  }
  return json({ intent_id: intent.id, status, amount_cents: intent.amount_cents });
});