const http = require('http');

function request(host, port, method, path, body, token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: host, port, path,
      method,
      headers: { 'Content-Type': 'application/json' }
    };
    if (token) options.headers['Authorization'] = 'Bearer ' + token;
    const req = http.request(options, res => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve({ status: res.statusCode, body: data }));
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function main() {
  // 1. Login via 8081 (user-service)
  console.log('=== 1. Login (8081) ===');
  const login = await request('localhost', 8081, 'POST', '/user/login', { username: 'admin', password: '123456' });
  console.log('Status:', login.status, 'Body:', login.body.substring(0, 200));
  const token = JSON.parse(login.body).data?.token;
  console.log('Token:', token ? 'OK' : 'NOT FOUND');

  if (!token) { console.log('Cannot proceed, no token'); return; }

  // 2. /user/profile (8081)
  console.log('\n=== 2. /user/profile (8081) ===');
  const p = await request('localhost', 8081, 'GET', '/user/profile', null, token);
  console.log('Status:', p.status, 'Body:', p.body.substring(0, 300));

  // 3. /novel/my (8082)
  console.log('\n=== 3. /novel/my (8082) ===');
  const my = await request('localhost', 8082, 'GET', '/novel/my?page=1&size=10', null, token);
  console.log('Status:', my.status, 'Body:', my.body.substring(0, 500));

  // 4. /novel/publish (8082)
  console.log('\n=== 4. /novel/publish (8082) ===');
  const pub = await request('localhost', 8082, 'POST', '/novel/publish', {
    title: 'Test Novel', author: 'Test Author', categoryId: 1,
    description: 'A test novel', tags: 'test'
  }, token);
  console.log('Status:', pub.status, 'Body:', pub.body.substring(0, 500));
}

main().catch(e => console.error('FATAL:', e));
