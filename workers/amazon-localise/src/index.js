// ABOUTME: Cloudflare Worker that rewrites Amazon product links at the edge to the visitor's local Amazon market.
// ABOUTME: Targets <a class="amzn" data-asin="..."> elements rendered by the theme's amazon shortcode.

// ISO 3166-1 alpha-2 country code (from request.cf.country) → Amazon TLD.
// Includes both real markets and known redirect-only domains (Amazon forwards them).
const MARKETS = {
  AE: 'ae',       // United Arab Emirates
  AU: 'com.au',   // Australia
  BR: 'com.br',   // Brazil
  CA: 'ca',       // Canada
  DE: 'de',       // Germany
  EG: 'eg',       // Egypt
  ES: 'es',       // Spain
  FR: 'fr',       // France
  GB: 'co.uk',    // United Kingdom
  IE: 'ie',       // Ireland
  IN: 'in',       // India
  IT: 'it',       // Italy
  JP: 'co.jp',    // Japan
  MX: 'com.mx',   // Mexico
  NL: 'nl',       // Netherlands
  PL: 'pl',       // Poland
  SA: 'sa',       // Saudi Arabia
  SE: 'se',       // Sweden
  SG: 'sg',       // Singapore
  TR: 'com.tr',   // Turkey
  US: 'com',      // United States
  ZA: 'co.za',    // South Africa
};

class LinkRewriter {
  constructor(tld) {
    this.tld = tld;
  }
  element(el) {
    const asin = el.getAttribute('data-asin');
    if (!asin) return;
    el.setAttribute('href', `https://www.amazon.${this.tld}/dp/${asin}`);
  }
}

export default {
  async fetch(request) {
    const origin = await fetch(request);
    const ct = origin.headers.get('content-type') || '';
    if (!ct.includes('text/html')) return origin;

    const tld = MARKETS[request.cf?.country];
    if (!tld) return origin;

    try {
      return new HTMLRewriter()
        .on('a.amzn[data-asin]', new LinkRewriter(tld))
        .transform(origin);
    } catch (e) {
      console.error('amazon-localise rewriter error', e);
      return origin;
    }
  },
};
