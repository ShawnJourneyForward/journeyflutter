import http from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const target = process.argv[2] === 'dist' ? 'dist' : 'src';
const publicRoot = path.join(root, target);
const port = Number(process.env.PORT || 4173);

const contentTypes = {
  '.css': 'text/css; charset=utf-8',
  '.html': 'text/html; charset=utf-8',
  '.jpg': 'image/jpeg',
  '.js': 'text/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.md': 'text/markdown; charset=utf-8',
  '.svg': 'image/svg+xml',
  '.webp': 'image/webp'
};

async function resolveRequest(urlPath) {
  const decoded = decodeURIComponent(urlPath.split('?')[0]);
  const safePath = path.normalize(decoded).replace(/^(\.\.[/\\])+/, '');
  let candidate = path.join(publicRoot, safePath);
  const info = await stat(candidate).catch(() => null);

  if (info?.isDirectory()) {
    candidate = path.join(candidate, 'index.html');
  }

  if (!info && !path.extname(candidate)) {
    candidate = path.join(candidate, 'index.html');
  }

  return candidate;
}

const server = http.createServer(async (request, response) => {
  try {
    const filePath = await resolveRequest(request.url || '/');
    const body = await readFile(filePath);
    response.writeHead(200, {
      'Content-Type': contentTypes[path.extname(filePath)] || 'application/octet-stream',
      'Cache-Control': 'no-cache'
    });
    response.end(body);
  } catch {
    response.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
    response.end('Not found');
  }
});

server.listen(port, () => {
  console.log(`Journey Forward site running at http://localhost:${port}`);
});
