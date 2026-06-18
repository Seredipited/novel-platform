const mysql = require('mysql2/promise');
const fs = require('fs');

async function main() {
  console.log('=== Connecting to MySQL ===');
  const conn = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '112233',
    charset: 'utf8mb4'
  });

  console.log('=== Dropping & Creating database ===');
  await conn.query('DROP DATABASE IF EXISTS novel_platform');
  await conn.query('CREATE DATABASE novel_platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
  await conn.query('USE novel_platform');

  console.log('=== Reading init.sql (UTF-8) ===');
  const sqlContent = fs.readFileSync('d:/IDEA/ssm/novel-platform/sql/init.sql', 'utf8');

  // Remove single-line comments
  let cleaned = sqlContent.replace(/--.*$/gm, '');
  
  // Split by semicolon
  let stmts = cleaned.split(';').map(s => s.trim()).filter(s => s.length > 0);
  
  console.log(`Found ${stmts.length} statements`);

  for (let i = 0; i < stmts.length; i++) {
    try {
      await conn.query(stmts[i]);
      console.log(`[${i+1}/${stmts.length}] OK`);
    } catch (e) {
      console.error(`[${i+1}/${stmts.length}] ERR: ${e.message.substring(0, 120)}`);
    }
  }

  // Verify
  console.log('\n=== Verifying ===');
  const [users] = await conn.query('SELECT id, username, nickname FROM novel_user');
  const [cats] = await conn.query('SELECT id, name FROM novel_category');
  const [novels] = await conn.query('SELECT id, title, author FROM novel LIMIT 5');

  console.log(`Users (${users.length}):`, JSON.stringify(users));
  console.log(`Categories (${cats.length}):`, JSON.stringify(cats));
  console.log(`Novels (${novels.length}):`, novels.map(n => n.title));

  await conn.end();
  console.log('\nDONE!');
}

main().catch(e => { console.error(e); process.exit(1); });
