function req(name: string): string {
  const v = Deno.env.get(name);
  if (!v) throw new Error(`Missing env var ${name}`);
  return v;
}

export const DEPOSIT_LIMITS = {
  minCents: Number(Deno.env.get("DEPOSIT_MIN_CENTS") ?? 1000),    // R10
  maxCents: Number(Deno.env.get("DEPOSIT_MAX_CENTS") ?? 500000),  // R5,000
  expiryMinutes: Number(Deno.env.get("DEPOSIT_EXPIRY_MINUTES") ?? 30),
};

export function stitchConfig() {
  return {
    clientId: req("STITCH_CLIENT_ID"),
    clientSecret: req("STITCH_CLIENT_SECRET"),
    webhookSecret: req("STITCH_WEBHOOK_SECRET"),       // Svix signing secret (whsec_...)
    redirectUri: req("STITCH_REDIRECT_URI"),           // https, domain allowlisted by Stitch
    tokenUrl: "https://secure.stitch.money/connect/token",
    apiBase: "https://api.stitch.money/v2",
    merchantId: Deno.env.get("STITCH_MERCHANT_ID") || undefined,       // optional
    beneficiaryJson: Deno.env.get("STITCH_BENEFICIARY_JSON") || undefined, // optional fallback
  };
}