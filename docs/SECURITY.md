# Security
- Passwords use bcrypt cost 12; session JWTs are signed, seven-day, HttpOnly, SameSite=Lax, and Secure in production.
- Tenant identifiers come from verified sessions. Nested ownership is checked server-side.
- Zod validates API input; Prisma parameterizes SQL. Login and AI endpoints are rate-limited.
- Security headers include CSP, frame denial, MIME protection, referrer and permissions policies.
- IP addresses are one-way pseudonymized before analytics storage. Secrets and raw API keys must never be stored or logged.
- Rotate `AUTH_SECRET`, database and provider keys periodically. Run dependency and application security review before each release.
