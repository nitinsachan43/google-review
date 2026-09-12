import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { db } from "./db";
import { SESSION_COOKIE, verifySession } from "./security";
export async function currentSession() {
  const token = (await cookies()).get(SESSION_COOKIE)?.value;
  if (!token) return null;
  try {
    const session = await verifySession(token);
    const membership = await db.tenantUser.findUnique({ where: { tenantId_userId: { tenantId: session.tenantId, userId: session.userId } }, include: { user: true, tenant: true } });
    if (!membership?.user.active || membership.tenant.status !== "ACTIVE") return null;
    return { ...session, membership };
  } catch { return null; }
}
export async function requireSession() { const s = await currentSession(); if (!s) redirect("/login"); return s; }
