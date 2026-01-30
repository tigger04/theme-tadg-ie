<!-- Version: 0.1 | Last updated: 2026-01-30 -->

# Contact Form with Cloudflare Turnstile CAPTCHA

A self-hosted contact form solution using a Cloudflare Worker backend, Cloudflare Turnstile CAPTCHA, and Resend for email delivery. Newsletter subscribers are stored in Cloudflare KV.

## Overview

The `contactform` shortcode replaces the simpler `formspree` shortcode with a fully self-hosted solution. It provides:

- **Turnstile CAPTCHA** — invisible bot protection (no puzzles for humans)
- **Email delivery via Resend** — contact form submissions forwarded to your inbox
- **Newsletter subscriber storage** — opted-in emails stored in Cloudflare KV
- **Zero cost** — all services have free tiers sufficient for personal sites

## Architecture

```
┌─────────────────────┐     POST      ┌──────────────────────┐
│  Hugo static site   │──────────────▶│  Cloudflare Worker   │
│                     │               │                      │
│  contactform        │               │  1. Validate Turnstile│
│  shortcode          │               │  2. Send email (Resend)│
│  + Turnstile widget │◀──────────────│  3. Store subscriber  │
│                     │   JSON resp   │     in KV (if opted in)│
└─────────────────────┘               └──────────────────────┘
```

The Hugo site is static — it renders the form with a Turnstile widget. On submit, client-side JS sends the form data as JSON to a Cloudflare Worker. The Worker validates the CAPTCHA token, sends an email via Resend, optionally stores the subscriber in KV, and returns a JSON response.

## Setup Guide

### Step 1: Create a Cloudflare account

1. Go to [dash.cloudflare.com/sign-up](https://dash.cloudflare.com/sign-up) and create a free account
2. Note your **Account ID** (visible on the dashboard overview page — you'll need it later)

### Step 2: Create a Turnstile widget

1. In the Cloudflare dashboard, click **Turnstile** in the left sidebar
2. Click **Add widget**
3. Set the widget name (e.g. "Contact Form")
4. Add your domain(s) (e.g. `tadg.ie`). Add `localhost` too if you want to test locally
5. Choose **Managed** mode (recommended — Cloudflare picks the best challenge type)
6. Click **Create**

You'll receive two values:
- **Site Key** — goes in your Hugo `hugo.yaml` (public, safe to commit)
- **Secret Key** — goes into the Worker as a secret (never commit this)

### Step 3: Create a Resend account

1. Sign up at [resend.com](https://resend.com) (free tier: 100 emails/day)
2. Go to **Domains** → **Add domain**
3. Follow the DNS verification steps (add the TXT, MX, and DKIM records Resend provides)
4. Wait for verification (usually under 5 minutes)
5. Go to **API Keys** → **Create API key** → copy it immediately (shown only once)

### Step 4: Install wrangler and deploy the Worker

```bash
# Navigate to the Worker directory
cd themes/tadg_ie/workers/contactform

# Install dependencies (includes wrangler)
npm install

# Authenticate with Cloudflare (opens browser)
npx wrangler login

# Deploy the Worker (KV namespace is auto-provisioned)
npx wrangler deploy
```

> **macOS note:** Avoid `npm install -g wrangler` — global installs on macOS
> require `sudo` or prefix configuration. Instead, use `npx wrangler` which
> runs the project-local copy installed by `npm install`.

After deploying, wrangler prints the Worker URL (e.g. `https://contactform.<your-account>.workers.dev`). Note this — it goes in your Hugo config.

### Step 5: Set Worker secrets

```bash
cd themes/tadg_ie/workers/contactform

# Turnstile secret key (from Step 2)
npx wrangler secret put TURNSTILE_SECRET_KEY

# Resend API key (from Step 3)
npx wrangler secret put RESEND_API_KEY

# Your email address (where contact form messages are sent)
npx wrangler secret put EMAIL_TO

# Sender address (must match your verified Resend domain)
npx wrangler secret put EMAIL_FROM

# Your site's origin (for CORS — must match exactly)
npx wrangler secret put ALLOWED_ORIGIN
```

Each command will prompt you to enter the value interactively — the secret is never visible in your terminal history.

### Step 6: Configure Hugo

Add the following to your site's `hugo.yaml`:

```yaml
params:
  contactform:
    worker_url: "https://contactform.<your-account>.workers.dev"
    turnstile_sitekey: "<your-turnstile-site-key>"
```

### Step 7: Use the shortcode

In any content file:

```markdown
{{< contactform >}}
```

Or with newsletter signup:

```markdown
{{< contactform newsletter="true" >}}
```

## Shortcode Parameters

| Parameter | Values | Default | Description |
|-----------|--------|---------|-------------|
| `newsletter` | `"true"` | (absent) | Show newsletter opt-in checkbox |

When `newsletter="true"`, the form includes a required checkbox. Opted-in emails are stored in Cloudflare KV for later retrieval.

## Managing Newsletter Subscribers

### List all subscribers

```bash
cd themes/tadg_ie/workers/contactform
npx wrangler kv key list --binding SUBSCRIBERS
```

### Read a specific subscriber

```bash
npx wrangler kv key get --binding SUBSCRIBERS "user@example.com"
```

Returns JSON: `{"name":"...","subscribed":"2026-01-30T..."}`

### Export all subscribers

```bash
npx wrangler kv key list --binding SUBSCRIBERS --prefix "" \
  | jq -r '.[].name' \
  | while read -r key; do
      value=$(npx wrangler kv key get --binding SUBSCRIBERS "$key" 2>/dev/null)
      printf '%s\t%s\n' "$key" "$value"
    done
```

### Delete a subscriber

```bash
npx wrangler kv key delete --binding SUBSCRIBERS "user@example.com"
```

## Hugo Configuration Reference

```yaml
params:
  contactform:
    worker_url: "https://contactform.example.workers.dev"  # Worker URL from Step 4
    turnstile_sitekey: "0x4AAAAAAA..."                     # Site key from Step 2
```

## Form Fields

| Field | Type | Required | Sent to Worker as |
|-------|------|----------|-------------------|
| Email | `email` | Yes | `email` |
| Name | `text` | No | `name` |
| Newsletter | `checkbox` | Yes (when shown) | `newsletter` |
| Message | `textarea` | Yes | `message` |
| Turnstile token | hidden | Auto | `cf-turnstile-response` |

## Input Limits

| Field | Max length |
|-------|-----------|
| Email | 254 characters |
| Name | 200 characters |
| Message | 10,000 characters |

## Security

- Turnstile tokens are validated server-side (mandatory — client-side alone provides no protection)
- Tokens expire after 5 minutes and are single-use
- CORS restricts requests to the configured origin
- Worker secrets are encrypted at rest and never appear in code
- Email content is HTML-escaped to prevent injection
- Input lengths are validated at the Worker boundary

## Costs

| Service | Free tier | Sufficient for |
|---------|-----------|----------------|
| Cloudflare Workers | 100,000 requests/day | ~100K form submissions/day |
| Cloudflare Turnstile | Unlimited | Unlimited |
| Cloudflare KV | 100K reads, 1K writes/day | ~1,000 subscriptions/day |
| Resend | 100 emails/day | ~100 form submissions/day |

## Troubleshooting

### Turnstile widget not appearing

- Check that `turnstile_sitekey` is set in `hugo.yaml`
- Verify your domain is listed in the Turnstile widget settings
- Check browser console for errors from `challenges.cloudflare.com`

### Form submission returns CORS error

- Verify `ALLOWED_ORIGIN` secret matches your site's origin exactly (including `https://`)
- Check that the origin doesn't have a trailing slash

### "CAPTCHA validation failed" error

- The Turnstile token may have expired (5 minute timeout) — the form resets the widget automatically
- Verify `TURNSTILE_SECRET_KEY` is set correctly as a Worker secret

### "Failed to send message" error

- Check that `RESEND_API_KEY` is valid
- Verify `EMAIL_FROM` uses a domain verified in Resend
- Check Resend dashboard for delivery logs

### No emails received

- Check spam folder
- Verify `EMAIL_TO` is set correctly
- Check Resend dashboard → Emails for delivery status

## Related

- [Cloudflare Turnstile docs](https://developers.cloudflare.com/turnstile/)
- [Cloudflare Workers docs](https://developers.cloudflare.com/workers/)
- [Cloudflare KV docs](https://developers.cloudflare.com/kv/)
- [Resend docs](https://resend.com/docs)
- Worker source and tests: `workers/contactform/`
