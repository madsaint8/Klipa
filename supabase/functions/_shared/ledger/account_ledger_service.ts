import { createClient, SupabaseClient } from "npm:@supabase/supabase-js@2";
import { getPaymentRequest } from "../stitch/stitch_client.ts";

export function adminClient(): SupabaseClient {
  return createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, {
    auth: { persistSession: false },
  });
}

// deno-lint-ignore no-explicit-any
type Intent = Record<string, any>;

/**
 * Source of truth = Stitch API, never the webhook body or the app redirect.
 * Safe to call repeatedly (webhook retries, polling): the SQL function is idempotent.
 */
export async function reconcileIntent(db: SupabaseClient, intent: Intent) {
  if (!intent.provider_payment_id) return { status: intent.status };
  if (["completed", "needs_review"].includes(intent.status)) return { status: intent.status };

  const pr = await getPaymentRequest(intent.provider_payment_id);

  if (pr.externalReference && pr.externalReference !== intent.id) {
    await db.from("deposit_intents")
      .update({ status: "needs_review", failure_reason: "external_reference_mismatch", last_provider_status: pr.status })
      .eq("id", intent.id);
    return { status: "needs_review" };
  }

  if (pr.status === "completed") {
    if (pr.amount.currency !== "ZAR") {
      await db.from("deposit_intents")
        .update({ status: "needs_review", failure_reason: "currency_mismatch" }).eq("id", intent.id);
      return { status: "needs_review" };
    }
    const paidCents = Math.round(Number(pr.amount.quantity) * 100);
    const { data, error } = await db.rpc("complete_deposit_intent", {
      p_intent_id: intent.id,
      p_provider_payment_id: pr.id,
      p_paid_amount_cents: paidCents,
      p_provider_status: pr.status,
    });
    if (error) throw error;
    return { status: data?.credited || data?.reason === "already_completed" ? "completed" : "needs_review", result: data };
  }

  if (pr.status === "cancelled" || pr.status === "expired") {
    await db.from("deposit_intents")
      .update({ status: pr.status, last_provider_status: pr.status })
      .eq("id", intent.id).in("status", ["created", "pending"]);
    return { status: pr.status };
  }

  await db.from("deposit_intents").update({ last_provider_status: pr.status }).eq("id", intent.id);
  return { status: "pending" };
}