import { siteConfig } from './config.js';

const currentPath = window.location.pathname.replace(/index\.html$/, '') || '/';
const navItems = [
  { href: '/', label: 'Home' },
  { href: '/privacy/', label: 'Privacy' },
  { href: '/about/', label: 'About' },
  { href: '/support/', label: 'Support' }
];

function iconMarkup() {
  return `
    <svg aria-hidden="true" viewBox="0 0 64 64">
      <path d="M31.5 46.5V24.5"></path>
      <path d="M31.7 28.5C26.7 29.1 22.4 26.3 20.5 21.5C26.3 20.8 30.4 23.2 31.7 28.5Z"></path>
      <path d="M32.2 35.2C37.6 35.9 42.1 32.9 44.1 27.4C38.2 26.8 34.1 29.5 32.2 35.2Z"></path>
    </svg>
  `;
}

function renderNav() {
  const node = document.querySelector('[data-site-nav]');
  if (!node) return;

  const links = navItems
    .map((item) => {
      const active = currentPath === item.href;
      return `<a href="${item.href}"${active ? ' aria-current="page"' : ''}>${item.label}</a>`;
    })
    .join('');

  node.innerHTML = `
    <header class="site-header">
      <div class="shell nav-shell">
        <a class="brand" href="/" aria-label="Journey Forward home">
          <span class="brand-mark">${iconMarkup()}</span>
          <span>Journey Forward</span>
        </a>
        <button class="nav-toggle" type="button" aria-expanded="false" aria-controls="site-menu">
          Menu
        </button>
        <nav id="site-menu" class="site-nav" aria-label="Primary navigation">
          ${links}
        </nav>
      </div>
    </header>
  `;

  const toggle = node.querySelector('.nav-toggle');
  const menu = node.querySelector('.site-nav');
  toggle?.addEventListener('click', () => {
    const expanded = toggle.getAttribute('aria-expanded') === 'true';
    toggle.setAttribute('aria-expanded', String(!expanded));
    menu?.classList.toggle('is-open', !expanded);
  });
}

function renderFooter() {
  const node = document.querySelector('[data-site-footer]');
  if (!node) return;

  node.innerHTML = `
    <footer class="site-footer">
      <div class="shell footer-grid">
        <div>
          <a class="brand footer-brand" href="/">
            <span class="brand-mark">${iconMarkup()}</span>
            <span>Journey Forward</span>
          </a>
          <p>Private recovery companion</p>
        </div>
        <div class="footer-links" aria-label="Footer navigation">
          <a href="/privacy/">Privacy</a>
          <a href="/support/">Support</a>
          <a href="/about/">About</a>
          <a href="mailto:${siteConfig.supportEmail}">${siteConfig.supportEmail}</a>
        </div>
      </div>
      <div class="shell footer-note">
        Journey Forward is not a replacement for professional medical advice, therapy, crisis care, or emergency services.
      </div>
    </footer>
  `;
}

function bindConfiguredLinks() {
  document.querySelectorAll('[data-support-email]').forEach((node) => {
    node.textContent = siteConfig.supportEmail;
    if (node instanceof HTMLAnchorElement) {
      node.href = `mailto:${siteConfig.supportEmail}`;
    }
  });
  document.querySelectorAll('[data-privacy-email]').forEach((node) => {
    node.textContent = siteConfig.privacyEmail;
    if (node instanceof HTMLAnchorElement) {
      node.href = `mailto:${siteConfig.privacyEmail}`;
    }
  });
}

renderNav();
renderFooter();
bindConfiguredLinks();
