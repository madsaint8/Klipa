import { stitchConfig } from "./stitch_config.ts";
import type { CreatePaymentRequestInput, StitchPaymentRequest } from "./stitch_types.ts";

let cached: { token: string; expiresAt: number } | null = null;

async function clientToken(): Promise<string> {
  if (cached && Date.now() < cached.expiresAt - 60_000) return cached.token;
  const c = stitchConfig();
  const res = await fetch(c.tokenUrl, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "client_credentials",
      client_id: c.clientId,
      client_secret: c.clientSecret,
      scope: "client_paymentrequest",
      audience: c.tokenUrl,
    }),
  });
  if (!res.ok) throw new Error(`stitch_token_failed:${res.status}`);
  const j = await res.json();
  cached = { token: j.access_token, expiresAt: Date.now() + j.expires_in * 1000 };
  return cached.token;
}

async function stitchFetch(path: string, init: RequestInit = {}): Promise<Response> {
  const c = stitchConfig();
  const doFetch = async () =>
    fetch(`${c.apiBase}${path}`, {
      ...init,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${await clientToken()}`,
        ...(init.headers ?? {}),
      },
    });
  let res = await doFetch();
  if (res.status === 401) { cached = null; res = await doFetch(); }
  return res;
}

export async function createPaymentRequest(input: CreatePaymentRequestInput): Promise<StitchPaymentRequest> {
  const c = stitchConfig();
  const eft: Record<string, unknown> = {
    enabled: true,
    payerReference: input.payerReference,            // max 12 chars
    beneficiaryReference: input.beneficiaryReference,
  };
  if (c.beneficiaryJson && !c.merchantId) eft.beneficiary = JSON.parse(c.beneficiaryJson);

  const body: Record<string, unknown> = {
    amount: { currency: "ZAR", quantity: input.amountCents / 100 },
    externalReference: input.externalReference,
    expireAt: input.expireAt,
    payer: input.payer,
    metadata: { klipa_intent_id: input.externalReference },
    paymentMethods: { eft, card: { enabled: false } }, // Pay by Bank only for now
  };
  if (c.merchantId) body.merchantId = c.merchantId;

  const res = await stitchFetch("/payment-requests", { method: "POST", body: JSON.stringify(body) });
  if (!res.ok) throw new Error(`stitch_create_failed:${res.status}:${await res.text()}`);
  return await res.json();
}

export async function getPaymentRequest(id: string): Promise<StitchPaymentRequest> {
  const res = await stitchFetch(`/payment-requests/${encodeURIComponent(id)}`);
  if (!res.ok) throw new Error(`stitch_get_failed:${res.status}`);
  return await res.json();
}

export function withRedirect(url: string, redirectUri: string): string {
  const u = new URL(url);
  u.searchParams.set("redirect_uri", redirectUri);
  return u.toString();
}