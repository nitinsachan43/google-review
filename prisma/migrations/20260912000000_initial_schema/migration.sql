-- Initial ReviewAI schema generated from prisma/schema.prisma.

CREATE TYPE "GlobalRole" AS ENUM ('USER', 'SUPPORT', 'PLATFORM_ADMIN', 'SUPER_ADMIN');

CREATE TYPE "TenantRole" AS ENUM ('OWNER', 'ADMIN', 'MANAGER', 'STAFF', 'VIEWER', 'AGENCY_OWNER', 'AGENCY_ADMIN', 'AGENCY_STAFF');

CREATE TYPE "Status" AS ENUM ('ACTIVE', 'INACTIVE', 'DISABLED', 'PENDING');

CREATE TYPE "SubscriptionStatus" AS ENUM ('TRIALING', 'ACTIVE', 'PAUSED', 'CANCELLED', 'EXPIRED', 'PAST_DUE');

CREATE TYPE "PaymentStatus" AS ENUM ('CREATED', 'AUTHORIZED', 'CAPTURED', 'FAILED', 'REFUNDED');

CREATE TABLE "User" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "email" TEXT NOT NULL UNIQUE,
  "name" TEXT NOT NULL,
  "passwordHash" TEXT NOT NULL,
  "globalRole" "GlobalRole" DEFAULT 'USER' NOT NULL,
  "active" BOOLEAN DEFAULT TRUE NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "deletedAt" TIMESTAMP(3)
);

CREATE TABLE "Session" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tokenHash" TEXT NOT NULL UNIQUE,
  "userId" TEXT NOT NULL,
  "expiresAt" TIMESTAMP(3) NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "Tenant" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "status" "Status" DEFAULT 'ACTIVE' NOT NULL,
  "trialStartedAt" TIMESTAMP(3),
  "trialEndsAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "deletedAt" TIMESTAMP(3)
);

CREATE TABLE "TenantUser" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "role" "TenantRole" NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "Business" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "industry" TEXT,
  "website" TEXT,
  "phone" TEXT,
  "email" TEXT,
  "description" TEXT,
  "address" TEXT,
  "country" TEXT,
  "state" TEXT,
  "city" TEXT,
  "postalCode" TEXT,
  "timezone" TEXT DEFAULT 'UTC' NOT NULL,
  "currency" TEXT DEFAULT 'INR' NOT NULL,
  "brandColor" TEXT DEFAULT '#2563eb' NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "deletedAt" TIMESTAMP(3)
);

CREATE TABLE "Location" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "businessId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "googlePlaceId" TEXT,
  "googleBusinessProfileId" TEXT,
  "googleMapsUrl" TEXT,
  "googleReviewUrl" TEXT,
  "address" TEXT,
  "phone" TEXT,
  "email" TEXT,
  "timezone" TEXT DEFAULT 'UTC' NOT NULL,
  "status" "Status" DEFAULT 'ACTIVE' NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "deletedAt" TIMESTAMP(3)
);

CREATE TABLE "QrCampaign" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "businessId" TEXT NOT NULL,
  "locationId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "type" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "status" "Status" DEFAULT 'ACTIVE' NOT NULL,
  "startDate" TIMESTAMP(3),
  "endDate" TIMESTAMP(3),
  "createdById" TEXT NOT NULL,
  "style" JSONB,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  "deletedAt" TIMESTAMP(3)
);

CREATE TABLE "QrCode" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "campaignId" TEXT NOT NULL,
  "format" TEXT NOT NULL,
  "size" INTEGER NOT NULL,
  "style" JSONB,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "QrScan" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "campaignId" TEXT NOT NULL,
  "visitorHash" TEXT,
  "device" TEXT,
  "browser" TEXT,
  "os" TEXT,
  "referrer" TEXT,
  "country" TEXT,
  "city" TEXT,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "ReviewSession" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "campaignId" TEXT NOT NULL,
  "visitorHash" TEXT,
  "googleClickedAt" TIMESTAMP(3),
  "copiedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "CustomerFeedback" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "locationId" TEXT NOT NULL,
  "campaignId" TEXT NOT NULL,
  "reviewSessionId" TEXT NOT NULL UNIQUE,
  "score" INTEGER NOT NULL,
  "comment" TEXT,
  "name" TEXT,
  "email" TEXT,
  "phone" TEXT,
  "consent" BOOLEAN DEFAULT FALSE NOT NULL,
  "status" TEXT DEFAULT 'UNRESOLVED' NOT NULL,
  "notes" TEXT,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "FeedbackTag" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "businessId" TEXT NOT NULL,
  "label" TEXT NOT NULL,
  "active" BOOLEAN DEFAULT TRUE NOT NULL
);

CREATE TABLE "FeedbackTagSelection" (
  "feedbackId" TEXT NOT NULL,
  "tagId" TEXT NOT NULL
);

CREATE TABLE "AiGeneration" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "campaignId" TEXT,
  "reviewSessionId" TEXT,
  "type" TEXT NOT NULL,
  "provider" TEXT NOT NULL,
  "model" TEXT NOT NULL,
  "inputTokens" INTEGER DEFAULT 0 NOT NULL,
  "outputTokens" INTEGER DEFAULT 0 NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "AiUsage" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "period" TEXT NOT NULL,
  "generations" INTEGER DEFAULT 0 NOT NULL,
  "tokens" INTEGER DEFAULT 0 NOT NULL
);

CREATE TABLE "GoogleConnection" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "status" TEXT NOT NULL,
  "accessTokenEncrypted" TEXT,
  "refreshTokenEncrypted" TEXT,
  "expiresAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "GoogleLocation" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "connectionId" TEXT NOT NULL,
  "locationId" TEXT NOT NULL,
  "externalId" TEXT NOT NULL
);

CREATE TABLE "GoogleReview" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "googleLocationId" TEXT NOT NULL,
  "externalId" TEXT NOT NULL,
  "reviewerName" TEXT,
  "rating" INTEGER NOT NULL,
  "comment" TEXT,
  "reviewedAt" TIMESTAMP(3) NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "GoogleReviewReply" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "reviewId" TEXT NOT NULL,
  "text" TEXT NOT NULL,
  "approvedById" TEXT,
  "sentAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "Plan" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "name" TEXT NOT NULL,
  "slug" TEXT NOT NULL UNIQUE,
  "active" BOOLEAN DEFAULT TRUE NOT NULL,
  "monthlyPrice" INTEGER NOT NULL,
  "currency" TEXT DEFAULT 'INR' NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "PlanFeature" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "planId" TEXT NOT NULL,
  "key" TEXT NOT NULL,
  "value" JSONB NOT NULL
);

CREATE TABLE "Subscription" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "planId" TEXT NOT NULL,
  "provider" TEXT NOT NULL,
  "status" "SubscriptionStatus" NOT NULL,
  "gatewaySubscriptionId" TEXT,
  "currentPeriodEnd" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "Payment" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "subscriptionId" TEXT,
  "gatewayPaymentId" TEXT,
  "amount" INTEGER NOT NULL,
  "currency" TEXT NOT NULL,
  "status" "PaymentStatus" NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "Invoice" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "subscriptionId" TEXT NOT NULL,
  "number" TEXT NOT NULL UNIQUE,
  "amount" INTEGER NOT NULL,
  "currency" TEXT NOT NULL,
  "status" TEXT NOT NULL,
  "issuedAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "Coupon" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "code" TEXT NOT NULL UNIQUE,
  "type" TEXT NOT NULL,
  "value" INTEGER NOT NULL,
  "active" BOOLEAN DEFAULT TRUE NOT NULL,
  "expiresAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "Agency" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL UNIQUE,
  "name" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "AgencyClient" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "agencyId" TEXT NOT NULL,
  "tenantId" TEXT NOT NULL UNIQUE,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "TeamInvitation" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "email" TEXT NOT NULL,
  "role" "TenantRole" NOT NULL,
  "tokenHash" TEXT NOT NULL UNIQUE,
  "invitedById" TEXT NOT NULL,
  "expiresAt" TIMESTAMP(3) NOT NULL,
  "acceptedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "Notification" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "userId" TEXT,
  "type" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "body" TEXT NOT NULL,
  "readAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "WebhookEndpoint" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "url" TEXT NOT NULL,
  "secretHash" TEXT NOT NULL,
  "active" BOOLEAN DEFAULT TRUE NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "WebhookDelivery" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "endpointId" TEXT NOT NULL,
  "event" TEXT NOT NULL,
  "payload" JSONB NOT NULL,
  "status" TEXT NOT NULL,
  "attempts" INTEGER DEFAULT 0 NOT NULL,
  "nextAttemptAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "BillingWebhookEvent" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "provider" TEXT NOT NULL,
  "eventId" TEXT NOT NULL,
  "eventType" TEXT NOT NULL,
  "payload" JSONB NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "ApiKey" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "prefix" TEXT NOT NULL,
  "keyHash" TEXT NOT NULL UNIQUE,
  "lastUsedAt" TIMESTAMP(3),
  "revokedAt" TIMESTAMP(3),
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "AuditLog" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT,
  "actorId" TEXT,
  "action" TEXT NOT NULL,
  "entity" TEXT NOT NULL,
  "entityId" TEXT,
  "metadata" JSONB,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE "SystemSetting" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "key" TEXT NOT NULL UNIQUE,
  "valueEncrypted" TEXT,
  "publicValue" JSONB,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "TenantSetting" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL UNIQUE,
  "reviewFlow" JSONB,
  "ai" JSONB,
  "notifications" JSONB,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "BrandSetting" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL UNIQUE,
  "platformName" TEXT,
  "logoUrl" TEXT,
  "faviconUrl" TEXT,
  "primaryColor" TEXT,
  "supportEmail" TEXT,
  "supportPhone" TEXT,
  "customDomain" TEXT,
  "updatedAt" TIMESTAMP(3) NOT NULL
);

CREATE TABLE "FileAsset" (
  "id" TEXT NOT NULL PRIMARY KEY,
  "tenantId" TEXT NOT NULL,
  "key" TEXT NOT NULL UNIQUE,
  "provider" TEXT NOT NULL,
  "mimeType" TEXT NOT NULL,
  "size" INTEGER NOT NULL,
  "createdAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX "User_email_idx" ON "User" ("email");

CREATE INDEX "Session_userId_idx" ON "Session" ("userId");

CREATE INDEX "Tenant_createdAt_idx" ON "Tenant" ("createdAt");

CREATE UNIQUE INDEX "TenantUser_tenantId_userId_key" ON "TenantUser" ("tenantId", "userId");

CREATE INDEX "TenantUser_tenantId_idx" ON "TenantUser" ("tenantId");

CREATE INDEX "Business_tenantId_idx" ON "Business" ("tenantId");

CREATE INDEX "Location_tenantId_idx" ON "Location" ("tenantId");

CREATE INDEX "Location_businessId_idx" ON "Location" ("businessId");

CREATE INDEX "QrCampaign_tenantId_idx" ON "QrCampaign" ("tenantId");

CREATE INDEX "QrCampaign_businessId_idx" ON "QrCampaign" ("businessId");

CREATE INDEX "QrCampaign_locationId_idx" ON "QrCampaign" ("locationId");

CREATE INDEX "QrCampaign_createdAt_idx" ON "QrCampaign" ("createdAt");

CREATE INDEX "QrCode_campaignId_idx" ON "QrCode" ("campaignId");

CREATE INDEX "QrScan_tenantId_idx" ON "QrScan" ("tenantId");

CREATE INDEX "QrScan_campaignId_createdAt_idx" ON "QrScan" ("campaignId", "createdAt");

CREATE INDEX "ReviewSession_tenantId_idx" ON "ReviewSession" ("tenantId");

CREATE INDEX "ReviewSession_campaignId_createdAt_idx" ON "ReviewSession" ("campaignId", "createdAt");

CREATE INDEX "CustomerFeedback_tenantId_idx" ON "CustomerFeedback" ("tenantId");

CREATE INDEX "CustomerFeedback_locationId_createdAt_idx" ON "CustomerFeedback" ("locationId", "createdAt");

CREATE UNIQUE INDEX "FeedbackTag_businessId_label_key" ON "FeedbackTag" ("businessId", "label");

CREATE INDEX "FeedbackTag_tenantId_idx" ON "FeedbackTag" ("tenantId");

CREATE INDEX "AiGeneration_tenantId_createdAt_idx" ON "AiGeneration" ("tenantId", "createdAt");

CREATE UNIQUE INDEX "AiUsage_tenantId_period_key" ON "AiUsage" ("tenantId", "period");

CREATE INDEX "GoogleConnection_tenantId_idx" ON "GoogleConnection" ("tenantId");

CREATE UNIQUE INDEX "GoogleLocation_connectionId_externalId_key" ON "GoogleLocation" ("connectionId", "externalId");

CREATE INDEX "GoogleLocation_tenantId_idx" ON "GoogleLocation" ("tenantId");

CREATE UNIQUE INDEX "GoogleReview_googleLocationId_externalId_key" ON "GoogleReview" ("googleLocationId", "externalId");

CREATE INDEX "GoogleReview_tenantId_reviewedAt_idx" ON "GoogleReview" ("tenantId", "reviewedAt");

CREATE INDEX "GoogleReviewReply_tenantId_idx" ON "GoogleReviewReply" ("tenantId");

CREATE UNIQUE INDEX "PlanFeature_planId_key_key" ON "PlanFeature" ("planId", "key");

CREATE INDEX "Subscription_tenantId_idx" ON "Subscription" ("tenantId");

CREATE INDEX "Payment_tenantId_createdAt_idx" ON "Payment" ("tenantId", "createdAt");

CREATE INDEX "Invoice_tenantId_idx" ON "Invoice" ("tenantId");

CREATE INDEX "TeamInvitation_tenantId_email_idx" ON "TeamInvitation" ("tenantId", "email");

CREATE INDEX "Notification_tenantId_createdAt_idx" ON "Notification" ("tenantId", "createdAt");

CREATE INDEX "WebhookEndpoint_tenantId_idx" ON "WebhookEndpoint" ("tenantId");

CREATE INDEX "WebhookDelivery_endpointId_createdAt_idx" ON "WebhookDelivery" ("endpointId", "createdAt");

CREATE UNIQUE INDEX "BillingWebhookEvent_provider_eventId_key" ON "BillingWebhookEvent" ("provider", "eventId");

CREATE INDEX "BillingWebhookEvent_provider_createdAt_idx" ON "BillingWebhookEvent" ("provider", "createdAt");

CREATE INDEX "ApiKey_tenantId_idx" ON "ApiKey" ("tenantId");

CREATE INDEX "AuditLog_tenantId_createdAt_idx" ON "AuditLog" ("tenantId", "createdAt");

CREATE INDEX "FileAsset_tenantId_idx" ON "FileAsset" ("tenantId");

ALTER TABLE "Session" ADD CONSTRAINT "Session_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "TenantUser" ADD CONSTRAINT "TenantUser_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "TenantUser" ADD CONSTRAINT "TenantUser_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Business" ADD CONSTRAINT "Business_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Location" ADD CONSTRAINT "Location_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "Business" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "QrCampaign" ADD CONSTRAINT "QrCampaign_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "Business" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "QrCampaign" ADD CONSTRAINT "QrCampaign_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "QrCode" ADD CONSTRAINT "QrCode_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "QrCampaign" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "QrScan" ADD CONSTRAINT "QrScan_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "QrCampaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "ReviewSession" ADD CONSTRAINT "ReviewSession_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "QrCampaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "CustomerFeedback" ADD CONSTRAINT "CustomerFeedback_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "CustomerFeedback" ADD CONSTRAINT "CustomerFeedback_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "QrCampaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "CustomerFeedback" ADD CONSTRAINT "CustomerFeedback_reviewSessionId_fkey" FOREIGN KEY ("reviewSessionId") REFERENCES "ReviewSession" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "FeedbackTag" ADD CONSTRAINT "FeedbackTag_businessId_fkey" FOREIGN KEY ("businessId") REFERENCES "Business" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "FeedbackTagSelection" ADD CONSTRAINT "FeedbackTagSelection_feedbackId_fkey" FOREIGN KEY ("feedbackId") REFERENCES "CustomerFeedback" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "FeedbackTagSelection" ADD CONSTRAINT "FeedbackTagSelection_tagId_fkey" FOREIGN KEY ("tagId") REFERENCES "FeedbackTag" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "AiGeneration" ADD CONSTRAINT "AiGeneration_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "QrCampaign" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "AiGeneration" ADD CONSTRAINT "AiGeneration_reviewSessionId_fkey" FOREIGN KEY ("reviewSessionId") REFERENCES "ReviewSession" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "AiUsage" ADD CONSTRAINT "AiUsage_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "GoogleLocation" ADD CONSTRAINT "GoogleLocation_connectionId_fkey" FOREIGN KEY ("connectionId") REFERENCES "GoogleConnection" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "GoogleLocation" ADD CONSTRAINT "GoogleLocation_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "GoogleReview" ADD CONSTRAINT "GoogleReview_googleLocationId_fkey" FOREIGN KEY ("googleLocationId") REFERENCES "GoogleLocation" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "GoogleReviewReply" ADD CONSTRAINT "GoogleReviewReply_reviewId_fkey" FOREIGN KEY ("reviewId") REFERENCES "GoogleReview" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "PlanFeature" ADD CONSTRAINT "PlanFeature_planId_fkey" FOREIGN KEY ("planId") REFERENCES "Plan" ("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Subscription" ADD CONSTRAINT "Subscription_planId_fkey" FOREIGN KEY ("planId") REFERENCES "Plan" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Payment" ADD CONSTRAINT "Payment_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Payment" ADD CONSTRAINT "Payment_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES "Subscription" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES "Subscription" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "AgencyClient" ADD CONSTRAINT "AgencyClient_agencyId_fkey" FOREIGN KEY ("agencyId") REFERENCES "Agency" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "AgencyClient" ADD CONSTRAINT "AgencyClient_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "TeamInvitation" ADD CONSTRAINT "TeamInvitation_invitedById_fkey" FOREIGN KEY ("invitedById") REFERENCES "User" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "WebhookEndpoint" ADD CONSTRAINT "WebhookEndpoint_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "WebhookDelivery" ADD CONSTRAINT "WebhookDelivery_endpointId_fkey" FOREIGN KEY ("endpointId") REFERENCES "WebhookEndpoint" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "ApiKey" ADD CONSTRAINT "ApiKey_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "AuditLog" ADD CONSTRAINT "AuditLog_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "TenantSetting" ADD CONSTRAINT "TenantSetting_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "BrandSetting" ADD CONSTRAINT "BrandSetting_tenantId_fkey" FOREIGN KEY ("tenantId") REFERENCES "Tenant" ("id") ON DELETE RESTRICT ON UPDATE CASCADE;
