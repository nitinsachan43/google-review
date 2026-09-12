# Razorpay setup
Create live/test keys and a webhook pointing to `/api/billing/razorpay/webhook`. Set the three Razorpay environment variables, select events for payments and subscriptions, and use the identical webhook secret. The endpoint verifies the raw body HMAC before acknowledging it. Complete a test-mode purchase and failed-payment rehearsal before live activation.
