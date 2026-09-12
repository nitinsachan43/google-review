import { createHash, createHmac, randomBytes, timingSafeEqual } from "crypto";
import { SignJWT, jwtVerify } from "jose";
import type { TenantRole } from "@prisma/client";

export const SESSION_COOKIE = "reviewai_session";
const developmentSecret = "development-only-change-me-32-characters";

if (process.env.NODE_ENV === "production" && !process.env.AUTH_SECRET) {
  throw new Error("AUTH_SECRET is required in production");
}

export function authSecret() {
  const configured = process.env.AUTH_SECRET;
  if (configured) return configured;
  if (process.env.NODE_ENV === "production") {
    throw new Error("AUTH_SECRET is required in production");
  }
  return developmentSecret;
}

const secret = () => new TextEncoder().encode(authSecret());
export async function signSession(data: { userId: string; tenantId: string; role: TenantRole }) {
  return new SignJWT(data).setProtectedHeader({ alg: "HS256" }).setIssuedAt().setExpirationTime("7d").sign(secret());
}
export async function verifySession(token: string) {
  const { payload } = await jwtVerify(token, secret());
  return payload as unknown as { userId: string; tenantId: string; role: TenantRole };
}
export const hashToken = (v: string) => createHash("sha256").update(v).digest("hex");
export const randomToken = () => randomBytes(32).toString("base64url");
export function verifyWebhook(body: string, signature: string | null, secret: string) {
  if (!signature || !secret) return false;
  const expected = createHmac("sha256", secret).update(body).digest("hex");
  const a = Buffer.from(expected); const b = Buffer.from(signature);
  return a.length === b.length && timingSafeEqual(a, b);
}
export function anonymizeIp(ip: string) { return createHash("sha256").update(ip + authSecret()).digest("hex").slice(0, 24); }
