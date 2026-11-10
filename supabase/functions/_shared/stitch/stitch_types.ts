export type StitchPaymentStatus = "pending" | "completed" | "cancelled" | "expired";

export interface StitchPaymentRequest {
  id: string;
  amount: { currency: string; quantity: number | string };
  externalReference?: string;
  expireAt?: string;
  status: StitchPaymentStatus;
  interaction?: { type: string; url: string };
}

export interface CreatePaymentRequestInput {
  amountCents: number;
  externalReference: string;
  payerReference: string;
  beneficiaryReference: string;
  expireAt: string;
  payer: { identifier: string; fullName?: string; email?: string };
}