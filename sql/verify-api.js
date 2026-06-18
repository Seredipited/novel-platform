const http = require('http');

function req(options) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', c => data += c);
      res.on('end', () => resolve(JSON.parse(data)));
    });
    req.on('error', reject);
    if (options.body) req.write(options.body);
    req.end();
  });
}

async function main() {
  // Login
  console.log('=== LOGIN ===');
  const loginRes = await req({
    hostname: 'localhost', port: 8081, path: '/user/login',
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username: 'admin', password: '123456' })
  });
  console.log('Login:', JSON.stringify(loginRes));

  if (loginRes.code !== 200) { console.log('Login failed!'); return; }
  const token = loginRes.data.token;

  // Profile
  console.log('\n=== PROFILE ===');
  const profileRes = await req({
    hostname: 'localhost', port: 8081, path: '/user/profile',
    headers: { 'Authorization': 'Bearer ' + token }
  });
  console.log('Profile nickname:', profileRes.data.nickname);
  console.log('Profile bio:', profileRes.data.bio);

  // Categories
  console.log('\n=== CATEGORIES ===');
  const catRes = await req({
    hostname: 'localhost', port: 8082, path: '/novel/categories'
  });
  catRes.data.forEach(c => console.log('Cat[' + c.id + ']:', c.name, '-', c.description));

  // Novel list
  console.log('\n=== NOVEL LIST ===');
  const novelRes = await req({
    hostname: 'localhost', port: 8082, path: '/novel/list?page=1&size=3'
  });
  novelRes.data.records.forEach(n =>
    console.log('Novel[' + n.id + ']:', n.title, '| author:', n.author)
  );

  console.log('\nDONE!');
}

main().catch(e => { console.error(e); process.exit(1); });
