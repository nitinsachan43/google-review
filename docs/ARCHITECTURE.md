# Architecture
ReviewAI is a Next.js App Router application with server-rendered marketing, dashboard, and public review surfaces. PostgreSQL and Prisma hold the normalized platform → tenant → business → location → campaign hierarchy. Every authenticated query derives `tenantId` from a signed HttpOnly session rather than request input. Central RBAC and database ownership checks prevent IDOR. Third-party integrations are isolated behind service/provider boundaries.

Public dynamic QR links create privacy-conscious scan and review-session records. AI receives only customer-supplied facts and returns an editable draft. It never posts. Payment amounts and state are accepted only from verified gateway webhooks.
