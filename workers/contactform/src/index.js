// ABOUTME: Cloudflare Worker handling contact form submissions.
// ABOUTME: Validates Turnstile CAPTCHA, sends email via Resend, stores newsletter subscribers in KV.

const MAX_EMAIL_LENGTH = 254;
const MAX_NAME_LENGTH = 200;
const MAX_MESSAGE_LENGTH = 10000;

const TURNSTILE_VERIFY_URL = "https://challenges.cloudflare.com/turnstile/v0/siteverify";
const RESEND_API_URL = "https://api.resend.com/emails";

export default {
  async fetch(request, env, ctx) {
    if (request.method === "OPTIONS") {
      return handlePreflight(request, env);
    }

    if (request.method !== "POST") {
      return jsonError("Method not allowed", 405);
    }

    const origin = request.headers.get("Origin") || "";
    const corsHeaders = buildCorsHeaders(origin, env.ALLOWED_ORIGIN);

    let body;
    try {
      body = await request.json();
    } catch {
      return jsonError("Invalid JSON", 400, corsHeaders);
    }

    const validationError = validateInput(body);
    if (validationError) {
      return jsonError(validationError, 400, corsHeaders);
    }

    const turnstileOk = await validateTurnstile(
      body["cf-turnstile-response"],
      env.TURNSTILE_SECRET_KEY,
      request.headers.get("CF-Connecting-IP")
    );
    if (!turnstileOk) {
      return jsonError("Turnstile CAPTCHA validation failed", 403, corsHeaders);
    }

    const emailOk = await sendEmail(env, body);
    if (!emailOk) {
      return jsonError("Failed to send message", 500, corsHeaders);
    }

    if (body.newsletter === "yes") {
      ctx.waitUntil(
        env.SUBSCRIBERS.put(
          body.email,
          JSON.stringify({
            name: body.name || "",
            subscribed: new Date().toISOString(),
          })
        )
      );
    }

    return jsonSuccess("Message sent", corsHeaders);
  },
};

function validateInput(body) {
  if (!body.email || typeof body.email !== "string" || body.email.trim() === "") {
    return "Email is required";
  }
  if (body.email.length > MAX_EMAIL_LENGTH) {
    return "Email exceeds maximum length";
  }
  if (!body.message || typeof body.message !== "string" || body.message.trim() === "") {
    return "Message is required";
  }
  if (body.message.length > MAX_MESSAGE_LENGTH) {
    return "Message exceeds maximum length";
  }
  if (body.name && body.name.length > MAX_NAME_LENGTH) {
    return "Name exceeds maximum length";
  }
  if (
    !body["cf-turnstile-response"] ||
    typeof body["cf-turnstile-response"] !== "string" ||
    body["cf-turnstile-response"].trim() === ""
  ) {
    return "Turnstile token is required";
  }
  return null;
}

async function validateTurnstile(token, secretKey, remoteIp) {
  const formData = new URLSearchParams();
  formData.append("secret", secretKey);
  formData.append("response", token);
  if (remoteIp) {
    formData.append("remoteip", remoteIp);
  }

  let resp;
  try {
    resp = await fetch(TURNSTILE_VERIFY_URL, {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: formData.toString(),
    });
  } catch (networkError) {
    console.error("Turnstile verification fetch failed:", networkError.message);
    return false;
  }

  let result;
  try {
    result = await resp.json();
  } catch (parseError) {
    console.error("Turnstile verification response not JSON:", parseError.message);
    return false;
  }

  return result.success === true;
}

async function sendEmail(env, body) {
  const htmlBody = `
    <p><strong>From:</strong> ${escapeHtml(body.email)}</p>
    ${body.name ? `<p><strong>Name:</strong> ${escapeHtml(body.name)}</p>` : ""}
    ${body.newsletter === "yes" ? "<p><strong>Newsletter:</strong> Yes, opted in</p>" : ""}
    <hr>
    <p>${escapeHtml(body.message).replace(/\n/g, "<br>")}</p>
  `;

  const resp = await fetch(RESEND_API_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${env.RESEND_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      from: env.EMAIL_FROM,
      to: [env.EMAIL_TO],
      subject: `Contact form: ${body.name || body.email}`,
      html: htmlBody,
      reply_to: body.email,
    }),
  });

  return resp.ok;
}

function escapeHtml(str) {
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

function handlePreflight(request, env) {
  const origin = request.headers.get("Origin") || "";
  const headers = buildCorsHeaders(origin, env.ALLOWED_ORIGIN);
  if (!headers["Access-Control-Allow-Origin"]) {
    return new Response(null, { status: 204 });
  }
  return new Response(null, { status: 204, headers });
}

function buildCorsHeaders(requestOrigin, allowedOrigin) {
  const headers = {};
  if (requestOrigin === allowedOrigin) {
    headers["Access-Control-Allow-Origin"] = allowedOrigin;
    headers["Access-Control-Allow-Methods"] = "POST, OPTIONS";
    headers["Access-Control-Allow-Headers"] = "Content-Type";
    headers["Access-Control-Max-Age"] = "86400";
  }
  return headers;
}

function jsonSuccess(message, corsHeaders = {}) {
  return new Response(JSON.stringify({ success: true, message }), {
    status: 200,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
}

function jsonError(error, status, corsHeaders = {}) {
  return new Response(JSON.stringify({ success: false, error }), {
    status,
    headers: { "Content-Type": "application/json", ...corsHeaders },
  });
}
