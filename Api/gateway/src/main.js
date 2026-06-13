const http = require('http');

const PORT = Number(process.env.PORT ?? 3003);
const BACKEND_URL = process.env.BACKEND_URL ?? 'http://127.0.0.1:3000';

function setCorsHeaders(res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS');
  res.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, Authorization'
  );
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = [];

    req.on('data', (chunk) => chunks.push(chunk));
    req.on('end', () => resolve(Buffer.concat(chunks)));
    req.on('error', reject);
  });
}

function buildTargetUrl(req) {
  const requestUrl = new URL(req.url, `http://localhost:${PORT}`);

  if (!requestUrl.pathname.startsWith('/api')) {
    return null;
  }

  const backendPath = requestUrl.pathname.replace(/^\/api/, '') || '/';
  return `${BACKEND_URL}${backendPath}${requestUrl.search}`;
}

function copyRequestHeaders(req, body) {
  const headers = { ...req.headers };

  delete headers.host;
  delete headers.connection;

  delete headers['content-length'];
  delete headers['transfer-encoding'];

  return headers;
}

const server = http.createServer(async (req, res) => {
  setCorsHeaders(res);

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const targetUrl = buildTargetUrl(req);

  if (!targetUrl) {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(
      JSON.stringify({
        success: false,
        message: 'Gunakan prefix /api untuk mengakses gateway',
      }),
    );
    return;
  }

  try {
    const body = await readBody(req);
    const response = await fetch(targetUrl, {
      method: req.method,
      headers: copyRequestHeaders(req, body),
      body: body.length ? body : undefined,
    });

    const responseBody = Buffer.from(await response.arrayBuffer());

    res.writeHead(response.status, {
      'Content-Type':
        response.headers.get('content-type') ?? 'application/json',
    });
    res.end(responseBody);
  } catch (error) {
    res.writeHead(502, { 'Content-Type': 'application/json' });
    res.end(
      JSON.stringify({
        success: false,
        message: 'Gateway gagal meneruskan request ke backend',
        error: error.message,
      }),
    );
  }
});

server.listen(PORT, () => {
  console.log(`Agroshop Gateway berjalan di http://localhost:${PORT}/api`);
  console.log(`Meneruskan request ke ${BACKEND_URL}`);
});
