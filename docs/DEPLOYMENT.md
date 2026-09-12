# Deployment
1. Create a dedicated PostgreSQL database and user; put credentials in `.env` with a 32+ byte `AUTH_SECRET`.
2. Run `pnpm install`, `pnpm prisma migrate deploy`, and the verification commands in README. The install creates a lockfile when one is not present; commit that lockfile before switching CI to frozen installs.
3. Start with `pnpm start` under a dedicated aaPanel Node Project/PM2 process on port 3000. Do not alter other applications.
4. In aaPanel, add only the ReviewAI domain and reverse proxy it to `127.0.0.1:3000`, preserving Host, X-Real-IP, X-Forwarded-For, and X-Forwarded-Proto.
5. Point DNS, issue Let's Encrypt in aaPanel, then enable HTTPS redirect.

Back up with `pg_dump -Fc reviewai > backups/reviewai-$(date +%F).dump`; encrypt off-host copies. Separately back up `.env` and uploaded assets with restricted permissions. Test restores quarterly. Never commit backups or secrets.
