// ABOUTME: Vitest configuration for Turnstile rejection tests.
// ABOUTME: Uses Cloudflare's "always fails" test secret key so all tokens are rejected.

import { readFileSync } from "node:fs";
import { defineWorkersConfig } from "@cloudflare/vitest-pool-workers/config";

function loadDevVars(path) {
  const content = readFileSync(path, "utf-8");
  const vars = {};
  for (const line of content.split("\n")) {
    const trimmed = line.trim();
    if (trimmed === "" || trimmed.startsWith("#")) {
      continue;
    }
    const eqIndex = trimmed.indexOf("=");
    if (eqIndex > 0) {
      vars[trimmed.slice(0, eqIndex)] = trimmed.slice(eqIndex + 1);
    }
  }
  return vars;
}

const devVars = loadDevVars("./.dev.vars");

export default defineWorkersConfig({
  test: {
    include: ["test/turnstile-reject.test.js"],
    poolOptions: {
      workers: {
        wrangler: { configPath: "./wrangler.toml" },
        miniflare: {
          kvNamespaces: ["SUBSCRIBERS"],
          bindings: {
            // "Always fails" test secret key — all tokens are rejected
            TURNSTILE_SECRET_KEY: devVars.TURNSTILE_SECRET_KEY_REJECT,
            RESEND_API_KEY: devVars.RESEND_API_KEY,
            EMAIL_TO: devVars.EMAIL_TO,
            EMAIL_FROM: devVars.EMAIL_FROM,
            ALLOWED_ORIGIN: devVars.ALLOWED_ORIGIN,
          },
        },
      },
    },
  },
});
