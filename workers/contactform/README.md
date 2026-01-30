# contactform Worker

Cloudflare Worker that handles contact form submissions with Turnstile CAPTCHA validation, email delivery via Resend, and newsletter subscriber storage in Cloudflare KV.

For full setup instructions, see [docs/contactform.md](../../docs/contactform.md).

## Quick Start

```bash
npm install
npm test
npx wrangler deploy
```

## Prerequisites

- [Node.js](https://nodejs.org/) (LTS)
- [wrangler](https://developers.cloudflare.com/workers/wrangler/) (installed locally via `npm install`; run with `npx wrangler`)
- A Cloudflare account with Turnstile widget configured
- A Resend account with a verified sending domain

## Development

```bash
# Run tests (uses Cloudflare's dummy test keys — no real API calls)
npm test

# Start local dev server
npm run dev
```

### Local development secrets

Copy `.dev.vars.example` to `.dev.vars` and fill in your values:

```bash
cp .dev.vars.example .dev.vars
```

The `.dev.vars` file is gitignored and used by `wrangler dev` and the test runner.

## Deployment

```bash
# Deploy the Worker (KV namespace auto-provisioned on first deploy)
npx wrangler deploy

# Set secrets (each prompts for the value interactively)
npx wrangler secret put TURNSTILE_SECRET_KEY
npx wrangler secret put RESEND_API_KEY
npx wrangler secret put EMAIL_TO
npx wrangler secret put EMAIL_FROM
npx wrangler secret put ALLOWED_ORIGIN
```

## Secrets Reference

| Secret | Description |
|--------|-------------|
| `TURNSTILE_SECRET_KEY` | Cloudflare Turnstile secret key for server-side token validation |
| `RESEND_API_KEY` | Resend API key for sending email |
| `EMAIL_TO` | Recipient email address for form submissions |
| `EMAIL_FROM` | Sender address (must be a verified domain in Resend) |
| `ALLOWED_ORIGIN` | CORS origin (e.g. `https://tadg.ie`) — must match exactly |

## Tests

Tests use [vitest](https://vitest.dev/) with [@cloudflare/vitest-pool-workers](https://developers.cloudflare.com/workers/testing/vitest-integration/) for local Workers runtime simulation.

Two test suites run with different Turnstile test keys:

| Suite | Config | Turnstile key | Purpose |
|-------|--------|---------------|---------|
| `test/index.test.js` | `vitest.config.js` | Always passes | Input validation, CORS, KV, email flow |
| `test/turnstile-reject.test.js` | `vitest.config.reject.js` | Always fails | Turnstile rejection behaviour |

## License

MIT License. Copyright Taḋg Paul.
