# ENHYPEN, WHERE TO START? — Deploy Package

This folder is ready for static deployment.

## Immediate deployment

You can deploy the folder as-is to any static host: Vercel, Netlify, GitHub Pages, Cloudflare Pages, etc.
There is no build step.

- Entry: `index.html`
- Static assets: `assets/`
- CSS: `styles.css`
- JS: `app.js`
- Runtime config: `config.js`

### Local preview

```bash
python -m http.server 8080
```

Then open `http://localhost:8080`.

## Fan participation modes

### 1) Default mode — deploy immediately

`config.js` ships with `sharedFanMode: false`.

The full UI works, including:
- FAN PICKS submission
- CONTENT POINT
- 🔥 💗 👀 reactions
- filters and view-more
- member dialog

Submissions/reactions are stored in each visitor's browser (`localStorage`). They are not shared between different visitors.

### 2) Shared fan mode — recommended for public launch

To make fan submissions and reaction counts visible to everyone:

1. Create a Supabase project.
2. Run `supabase-schema.sql` in Supabase SQL Editor.
3. Open `config.js` and set:

```js
window.ENHYPEN_CONFIG = {
  supabaseUrl: "https://YOUR_PROJECT.supabase.co",
  supabaseAnonKey: "YOUR_ANON_OR_PUBLISHABLE_KEY",
  sharedFanMode: true
};
```

4. Redeploy.

The public anon/publishable key is intentionally used in browser apps; do **not** paste a service-role key.

Shared mode supports:
- public FAN PICKS feed
- shared 🔥 💗 👀 reaction counts
- 1MB or smaller fan thumbnail uploads to `fan-thumbnails`
- YouTube/Shorts thumbnail auto-detection when no image is uploaded

## Files for hosting

- `vercel.json` — Vercel static settings and security headers
- `netlify.toml` — Netlify publish settings and security headers
- `404.html` — static-host fallback
- `robots.txt`
- `site.webmanifest`
- `favicon.svg`

## Important prototype note

This is a fan-curation prototype. For a real public campaign, add moderation / abuse prevention before enabling unrestricted fan submissions at scale.
