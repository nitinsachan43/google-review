import { createHash } from "crypto";
import { NextResponse } from "next/server";
import type { PaymentStatus, Prisma, SubscriptionStatus } from "@prisma/client";
import { db } from "@/lib/db";
import { verifyWebhook } from "@/lib/security";

type RazorpayEntity = {
  id?: string;
  amount?: number;
  currency?: string;
  status?: string;
  subscription_id?: string;
  current_end?: number;
  notes?: Record<string, string>;
};

type RazorpayEvent = {
  event: string;
  payload?: {
    payment?: { entity?: RazorpayEntity };
    subscription?: { entity?: RazorpayEntity };
  };
};

const paymentStatuses: Record<string, PaymentStatus> = {
  "payment.authorized": "AUTHORIZED",
  "payment.captured": "CAPTURED",
  "payment.failed": "FAILED",
  "payment.refunded": "REFUNDED",
};

const subscriptionStatuses: Record<string, SubscriptionStatus> = {
  "subscription.authenticated": "ACTIVE",
  "subscription.activated": "ACTIVE",
  "subscription.charged": "ACTIVE",
  "subscription.pending": "PAST_DUE",
  "subscription.halted": "PAST_DUE",
  "subscription.paused": "PAUSED",
  "subscription.resumed": "ACTIVE",
  "subscription.cancelled": "CANCELLED",
  "subscription.completed": "EXPIRED",
};

function unixDate(value?: number) {
  return value ? new Date(value * 1000) : undefined;
}

export async function POST(req: Request) {
  const body = await req.text();
  if (!verifyWebhook(body, req.headers.get("x-razorpay-signature"), process.env.RAZORPAY_WEBHOOK_SECRET || "")) {
    return NextResponse.json({ error: "Invalid signature" }, { status: 401 });
  }

  let event: RazorpayEvent;
  try {
    event = JSON.parse(body) as RazorpayEvent;
  } catch {
    return NextResponse.json({ error: "Invalid JSON payload" }, { status: 400 });
  }
  if (!event.event) return NextResponse.json({ error: "Missing event type" }, { status: 400 });

  const eventId = req.headers.get("x-razorpay-event-id") || createHash("sha256").update(body).digest("hex");
  try {
    await db.$transaction(async (tx) => {
      const seen = await tx.billingWebhookEvent.findUnique({
        where: { provider_eventId: { provider: "razorpay", eventId } },
      });
      if (seen) return;

      const payment = event.payload?.payment?.entity;
      const subscriptionEntity = event.payload?.subscription?.entity;
      const gatewaySubscriptionId = subscriptionEntity?.id || payment?.subscription_id;
      const subscription = gatewaySubscriptionId
        ? await tx.subscription.findFirst({ where: { provider: "razorpay", gatewaySubscriptionId } })
        : null;

      const subscriptionStatus = subscriptionStatuses[event.event];
      if (subscriptionStatus && gatewaySubscriptionId) {
        if (!subscription) throw new Error(`Unknown Razorpay subscription ${gatewaySubscriptionId}`);
        await tx.subscription.update({
          where: { id: subscription.id },
          data: { status: subscriptionStatus, currentPeriodEnd: unixDate(subscriptionEntity?.current_end) },
        });
      }

      const paymentStatus = paymentStatuses[event.event];
      if (paymentStatus && payment?.id) {
        if (!subscription) throw new Error(`No local subscription for Razorpay payment ${payment.id}`);
        const existing = await tx.payment.findFirst({ where: { gatewayPaymentId: payment.id } });
        const data = {
          tenantId: subscription.tenantId,
          subscriptionId: subscription.id,
          gatewayPaymentId: payment.id,
          amount: payment.amount ?? 0,
          currency: (payment.currency || "INR").toUpperCase(),
          status: paymentStatus,
        };
        if (existing) await tx.payment.update({ where: { id: existing.id }, data });
        else await tx.payment.create({ data });
      }

      await tx.billingWebhookEvent.create({
        data: { provider: "razorpay", eventId, eventType: event.event, payload: event as unknown as Prisma.InputJsonValue },
      });
    });
  } catch (error) {
    console.error("Razorpay webhook processing failed", error);
    return NextResponse.json({ error: "Webhook processing failed" }, { status: 500 });
  }

  return NextResponse.json({ received: true });
}
