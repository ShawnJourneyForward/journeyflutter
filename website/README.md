# Journey Forward website

Static marketing site for [journeyforward.app](https://journeyforward.app), built from the actual Flutter app’s design language and copy.

## Stack

- Plain HTML, CSS, and JavaScript
- No backend
- No analytics, cookies, trackers, or external font loading
- Static build output in `dist/`

## Run locally

```bash
npm install
npm run dev
```

Open `http://localhost:4173`.

## Build

```bash
npm run build
```

The deployable static site is generated in `dist/`.

## Deploy

This site can be deployed as a static project to Cloudflare Pages, Netlify, Vercel, or any static host.

- Build command: `npm run build`
- Output directory: `dist`

## Configurable values

Edit `src/assets/js/config.js` before publishing:

- `androidDownloadUrl`
- `iosWaitlistUrl`
- `iosSupportUrl`
- `supportEmail`
- `privacyEmail`

The current defaults are safe placeholders where the final public links are not yet confirmed.

## Screenshots and assets

Real app screenshots already used by the site live in `src/assets/images/screenshots/`.

Additional screenshot guidance is in:

`src/assets/images/screenshots/README.md`

Use real captures from the Flutter app only. Do not replace them with generic mockups or invented UI.

## Source-of-truth notes

The site was built from the Flutter app’s current palette, copy, and supported features. The privacy page is intentionally precise: it avoids claiming absolute “never leaves the phone” language while Android backup behavior and runtime font fetching still need final release cleanup in the app.
