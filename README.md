# ReviewAI

Production-oriented, multi-tenant SaaS foundation for dynamic Google Review QR campaigns, genuine AI-assisted review drafting, customer feedback, and analytics.

## Stack and architecture
Next.js App Router, React, TypeScript, PostgreSQL, Prisma, Zod, bcrypt, signed HttpOnly sessions, OpenAI Responses API, and QRCode. The normalized schema includes tenant RBAC, businesses/locations/campaigns, analytics, feedback, Google connection/review records, plans/subscriptions/payments, agencies, teams, branding, API keys, webhooks, audit records, and settings. See [architecture](docs/ARCHITECTURE.md) and [security](docs/SECURITY.md).

## Local development
```bash
cp .env.example .env
pnpm install
# create a dedicated PostgreSQL database first
pnpm prisma migrate dev --name initial
pnpm dev
```
Demo data is opt-in only: `ALLOW_DEMO_SEED=true pnpm db:seed`. Its password must be changed immediately and it must never be used in production.

## Verification
```bash
pnpm lint
pnpm typecheck
pnpm test
pnpm build
```

## Configuration
Every supported variable is documented in `.env.example`. Required for core production are `APP_URL`, `APP_DOMAIN`, `DATABASE_URL`, and a random `AUTH_SECRET` of at least 32 bytes. OpenAI, Google, Razorpay, Stripe, SMTP, Redis, and S3/R2 values are optional: related integration functionality remains disconnected until configured. Never expose or commit `.env`.

## Deployment on aaPanel
This repository deliberately does not overwrite shared Nginx, databases, PM2, certificates, or websites. Follow [deployment](docs/DEPLOYMENT.md). Create a dedicated Node Project on port 3000, run migrations before the application, and paste only `deploy/nginx.reviewai.conf.example` into this site's vhost. Issue Let's Encrypt only after DNS points to the server. The current execution environment did not expose `/www`, aaPanel, Nginx, Docker, PM2, or PostgreSQL, so server deployment must occur on the actual VPS.

## Integrations
- [Google Business Profile and Places](docs/GOOGLE_SETUP.md)
- [OpenAI](docs/AI_SETUP.md)
- [Razorpay](docs/RAZORPAY_SETUP.md)

## Operations and troubleshooting
- Apply versioned migrations with `pnpm prisma migrate deploy`; never use destructive schema push in production.
- Check the aaPanel Node Project log and `curl -I http://127.0.0.1:3000` before enabling proxying.
- A database error means PostgreSQL is unreachable or `DATABASE_URL` is invalid.
- A friendly template draft instead of AI means `OPENAI_API_KEY` is absent.
- A rejected Razorpay webhook means its raw-body signature or secret does not match.
- Back up PostgreSQL, assets, `.env`, and the site-specific vhost; encrypt copies and periodically test restore. Exact commands are in deployment docs.
