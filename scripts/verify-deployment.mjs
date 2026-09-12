const baseUrl = process.argv.slice(2).find((argument) => argument !== "--") || process.env.APP_URL;

if (!baseUrl) {
  console.error("Usage: node scripts/verify-deployment.mjs https://review.example.com");
  process.exit(2);
}

const origin = new URL(baseUrl).origin;
const checks = [
  { path: "/", content: "ReviewAI" },
  { path: "/api/health", content: '"status":"ok"' },
];

for (const check of checks) {
  const url = new URL(check.path, origin);
  let response;
  try {
    response = await fetch(url, { redirect: "follow", signal: AbortSignal.timeout(10_000) });
  } catch (error) {
    console.error(`FAIL ${url}: ${error.message}`);
    process.exit(1);
  }

  const body = await response.text();
  if (!response.ok || !body.includes(check.content)) {
    console.error(`FAIL ${url}: HTTP ${response.status}`);
    process.exit(1);
  }
  console.log(`PASS ${url}: HTTP ${response.status}`);
}

console.log(`ReviewAI is live at ${origin}`);
