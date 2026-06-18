const http = require('http');

function request(method, path, body, token) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 8082,
      path,
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
  // 1. Login to get token
  console.log('=== 1. Login ===');
  const login = await request('POST', '/user/login', { username: 'admin', password: '123456' });
  console.log('Status:', login.status);
  console.log('Body:', login.body);
  const token = JSON.parse(login.body).data?.token;
  console.log('Token:', token ? token.substring(0, 30) + '...' : 'NOT FOUND');

  // 2. Test /user/profile via user-service directly
  console.log('\n=== 2. /user/profile (direct 8081) ===');
  try {
    const profile = await request('GET', '/user/profile', null, token);
    console.log('Status:', profile.status);
    console.log('Body:', profile.body.substring(0, 300));
  } catch (e) { console.log('ERROR:', e.message); }

  // 3. Test /novel/categories
  console.log('\n=== 3. /novel/categories (8082) ===');
  try {
    const cats = await request('GET', '/novel/categories');
    console.log('Status:', cats.status);
    console.log('Body:', cats.body.substring(0, 300));
  } catch (e) { console.log('ERROR:', e.message); }

  // 4. Test /novel/my
  console.log('\n=== 4. /novel/my (8082) ===');
  try {
    const my = await request('GET', '/novel/my?page=1&size=10', null, token);
    console.log('Status:', my.status);
    console.log('Body:', my.body.substring(0, 500));
  } catch (e) { console.log('ERROR:', e.message); }

  // 5. Test /novel/publish
  console.log('\n=== 5. /novel/publish (8082) ===');
  try {
    const pub = await request('POST', '/novel/publish', {
      title: 'Test Novel',
      author: 'Test Author',
      categoryId: 1,
      description: 'A test novel description',
      tags: 'test,sample'
    }, token);
    console.log('Status:', pub.status);
    console.log('Body:', pub.body.substring(0, 500));
  } catch (e) { console.log('ERROR:', e.message); }
}

main().catch(e => console.error('FATAL:', e.message));
