const mysql = require('mysql2/promise');

async function main() {
  const conn = await mysql.createConnection({
    host: 'localhost', user: 'root', password: '112233',
    charset: 'utf8mb4'
  });

  // Test 1: Check raw bytes
  console.log('=== Test raw string ===');
  const testStr = '文澜阁';
  console.log('JS string:', testStr);
  console.log('Buffer hex:', Buffer.from(testStr).toString('hex')); // should be e68987e6b98fe99893

  await conn.query('USE novel_platform');
  
  // Test 2: Create temp table and insert
  await conn.query('DROP TABLE IF EXISTS _test_enc');
  await conn.query('CREATE TABLE _test_enc (id INT PRIMARY KEY, val VARCHAR(100)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4');

  // Insert using parameterized query
  await conn.query('INSERT INTO _test_enc VALUES(1, ?)', [testStr]);
  
  // Read back as hex
  const [rows] = await conn.query('SELECT id, HEX(val) AS hexval, val FROM _test_enc WHERE id=1');
  console.log('Stored hex:', rows[0].hexval); // should be E68987E6B98FE99893
  console.log('Read back:', rows[0].val);

  // Test 3: Check actual table encoding
  const [info] = await conn.query(`
    SELECT TABLE_NAME, TABLE_COLLATION 
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA='novel_platform' AND TABLE_NAME='novel_user'
  `);
  console.log('Table collation:', JSON.stringify(info[0]));

  // Test 4: Direct SQL without parameters
  const directStr = '\u6587\u6f9c\u9601'; // 文澜阁 as unicode escape
  console.log('Direct str:', directStr);
  console.log('Direct hex:', Buffer.from(directStr).toString('hex'));
  await conn.query('INSERT INTO _test_enc VALUES(2, ?)', [directStr]);
  const [rows2] = await conn.query('SELECT HEX(val) AS h, val FROM _test_enc WHERE id=2');
  console.log('Direct stored hex:', rows2[0].h);
  console.log('Direct read back:', rows2[0].val);

  // Clean up
  await conn.query('DROP TABLE IF EXISTS _test_enc');
  await conn.end();
}

main().catch(e => { console.error(e); process.exit(1); });
