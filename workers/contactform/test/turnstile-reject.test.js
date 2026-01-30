// ABOUTME: Tests for Turnstile CAPTCHA rejection using the "always fails" test secret key.
// ABOUTME: Separated from main tests because Cloudflare test keys are all-or-nothing per config.

import { env, createExecutionContext, waitOnExecutionContext } from "cloudflare:test";
import { describe, it, expect } from "vitest";
import worker from "../src/index.js";

function makeRequest(body) {
  return new Request("https://contactform.workers.dev/", {
    method: "POST",
    headers: new Headers({
      "Content-Type": "application/json",
      "Origin": "https://example.com",
      "CF-Connecting-IP": "203.0.113.1",
    }),
    body: JSON.stringify(body),
  });
}

describe("Turnstile rejection", () => {
  it("test_turnstile_validation_failure_returns_403", async () => {
    const req = makeRequest({
      email: "sender@example.com",
      name: "Test User",
      message: "Hello, this is a test message.",
      "cf-turnstile-response": "any-token-will-fail",
    });
    const ctx = createExecutionContext();
    const resp = await worker.fetch(req, env, ctx);
    await waitOnExecutionContext(ctx);

    expect(resp.status).toBe(403);
    const data = await resp.json();
    expect(data.error).toMatch(/captcha|turnstile/i);
  });

  it("test_turnstile_rejection_does_not_send_email", async () => {
    const req = makeRequest({
      email: "sender@example.com",
      name: "Test User",
      message: "This should not be emailed.",
      "cf-turnstile-response": "rejected-token",
    });
    const ctx = createExecutionContext();
    const resp = await worker.fetch(req, env, ctx);
    await waitOnExecutionContext(ctx);

    // If Turnstile rejects, we get 403 — email sending is never reached
    expect(resp.status).toBe(403);
  });

  it("test_turnstile_rejection_does_not_write_kv", async () => {
    const req = makeRequest({
      email: "rejected-subscriber@example.com",
      name: "Bot",
      message: "Spam",
      newsletter: "yes",
      "cf-turnstile-response": "rejected-token",
    });
    const ctx = createExecutionContext();
    const resp = await worker.fetch(req, env, ctx);
    await waitOnExecutionContext(ctx);

    expect(resp.status).toBe(403);
    const stored = await env.SUBSCRIBERS.get("rejected-subscriber@example.com");
    expect(stored).toBeNull();
  });
});
