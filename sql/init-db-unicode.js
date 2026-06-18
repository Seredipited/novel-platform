const mysql = require('mysql2/promise');

async function main() {
  const conn = await mysql.createConnection({
    host: 'localhost', user: 'root', password: '112233',
    charset: 'utf8mb4'
  });

  console.log('=== Rebuilding database ===');
  await conn.query('DROP DATABASE IF EXISTS novel_platform');
  await conn.query(`CREATE DATABASE novel_platform DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
  await conn.query('USE novel_platform');

  // Tables
  await conn.query(`
    CREATE TABLE novel_user (
      id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
      username VARCHAR(50) NOT NULL UNIQUE,
      password VARCHAR(200) NOT NULL,
      nickname VARCHAR(50) DEFAULT NULL,
      email VARCHAR(100) DEFAULT NULL,
      avatar VARCHAR(255) DEFAULT NULL,
      bio VARCHAR(500) DEFAULT NULL,
      gender TINYINT DEFAULT 0,
      deleted TINYINT DEFAULT 0,
      create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
      update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);

  await conn.query(`
    CREATE TABLE novel_category (
      id INT PRIMARY KEY AUTO_INCREMENT,
      name VARCHAR(50) NOT NULL,
      description VARCHAR(200) DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);

  await conn.query(`
    CREATE TABLE novel (
      id BIGINT PRIMARY KEY AUTO_INCREMENT,
      title VARCHAR(200) NOT NULL,
      author VARCHAR(100) DEFAULT NULL,
      author_id BIGINT DEFAULT NULL,
      category_id INT DEFAULT NULL,
      description TEXT,
      cover_img VARCHAR(500) DEFAULT NULL,
      status VARCHAR(20) DEFAULT 'ongoing',
      score DECIMAL(3,1) DEFAULT 0.0,
      word_count BIGINT DEFAULT 0,
      click_count BIGINT DEFAULT 0,
      favorite_count BIGINT DEFAULT 0,
      tags VARCHAR(500) DEFAULT NULL,
      deleted TINYINT DEFAULT 0,
      create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
      update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);

  await conn.query(`
    CREATE TABLE novel_chapter (
      id BIGINT PRIMARY KEY AUTO_INCREMENT,
      novel_id BIGINT NOT NULL,
      title VARCHAR(200) NOT NULL,
      content MEDIUMTEXT,
      chapter_number INT NOT NULL,
      word_count BIGINT DEFAULT 0,
      create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
      update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_novel_id (novel_id),
      INDEX idx_novel_chapter (novel_id, chapter_number)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
  `);
  console.log('Tables created.');

  // Categories
  const categories = [
    [1, '\u7384\u5e9b', '\u4e1c\u65b9\u7384\u5e9b\u3001\u5f02\u754c\u5927\u9646\u3001\u671d\u6cbb\u4e89\u9738'],
    [2, '\u4ed9\u4fa0', '\u4fee\u771f\u6587\u660e\u3001\u795e\u8bdd\u5fd7\u602a\u3001\u73b0\u4ee3\u4fee\u771f'],
    [3, '\u90fd\u5e02', '\u90fd\u5e02\u751f\u6d3b\u3001\u90fd\u5e02\u5f02\u80fd\u3001\u90fd\u5e02\u7231\u60c5'],
    [4, '\u5386\u53f2', '\u5386\u53f2\u7a7f\u8d8a\u3001\u67b6\u7a7a\u5386\u53f2\u3001\u53e4\u4ee3\u6218\u4e89'],
    [5, '\u79d1\u5e7b', '\u661f\u9645\u6587\u660e\u3001\u672a\u6765\u4e16\u754c\u3001\u672a\u4e16\u5371\u673a'],
    [6, '\u60ac\u7591', '\u63a8\u7406\u4fa6\u63a2\u3001\u7075\u5f02\u60ca\u61fd\u3001\u5192\u9669\u89e3\u8c1c'],
    [7, '\u6e38\u620f', '\u6e38\u620f\u7ade\u6280\u3001\u6e38\u620f\u5f02\u754c\u3001\u7535\u5b50\u7ade\u6280'],
    [8, '\u8a00\u60c5', '\u53e4\u4ee3\u8a00\u60c5\u3001\u73b0\u4ee3\u8a00\u60c5\u3001\u6d6a\u6f2b\u9752\u6625']
  ];
  for (const c of categories) await conn.query('INSERT INTO novel_category (id,name,description) VALUES(?,?,?)', c);
  console.log('Categories inserted:', categories.length);

  // Users (password MD5 of "123456")
  const users = [
    [1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', '\u6587\u6f9c\u9601\u4e3b', '\u6587\u6f9c\u9601\u7684\u5b88\u62a4\u8005\uff0c\u71ed\u7231\u9605\u8bfb\u4e0e\u521b\u4f5c\u3002'],
    [2, 'author_wang', 'e10adc3949ba59abbe56e057f20f883e', '\u58a8\u9999\u4e66\u7ae5', '\u4e00\u652f\u7b14\uff0c\u5199\u5c3d\u4e16\u95f4\u51b7\u6696\u3002'],
    [3, 'reader_li', 'e10adc3949ba59abbe56e057f20f883e', '\u4e66\u866b\u5c0f\u674e', '\u8bfb\u4e66\u7834\u4e07\u5377\uff0c\u4e0b\u7b14\u5982\u6709\u795e\u3002']
  ];
  for (const u of users) await conn.query('INSERT INTO novel_user (id,username,password,nickname,bio) VALUES(?,?,?,?,?)', u);
  console.log('Users inserted:', users.length);

  // Novels
  const novels = [
    [1, '\u661f\u8fb0\u53d8', '\u58a8\u9999\u4e66\u7ae5', 2, 1, '\u5728\u6d69\u7eaf\u7684\u661f\u8fb0\u5927\u6d77\u4e2d\uff0c\u4e00\u4e2a\u5c11\u5e74\u8e0f\u4e0a\u4e86\u4fee\u4ed9\u4e4b\u8def\u3002', 'ongoing', 8.5, 1520000, 25800, 3200, '\u7384\u5e9b,\u4fee\u4ed9,\u70ed\u8840'],
    [2, '\u90fd\u5e02\u5947\u7f18', '\u58a8\u9999\u4e66\u7ae5', 2, 3, '\u5e73\u51e1\u7684\u5927\u5b66\u751f\u6797\u9038\u5728\u4e00\u6b21\u610f\u5916\u4e2d\u83b7\u5f97\u4e86\u795e\u79d8\u7684\u80fd\u529b\u3002', 'ongoing', 7.8, 890000, 18600, 2100, '\u90fd\u5e02,\u5f02\u80fd,\u8f7b\u677e'],
    [3, '\u5927\u5510\u98ce\u534e\u5f55', '\u6587\u6f9c\u9601\u4e3b', 1, 4, '\u4e00\u4e2a\u73b0\u4ee3\u5386\u53f2\u7cfb\u5b66\u751f\u610f\u5916\u7a7f\u8d8a\u5230\u5927\u5510\u8d1e\u89c2\u5e74\u95f4\u3002', 'completed', 9.2, 2100000, 45200, 5600, '\u5386\u53f2,\u7a7f\u8d8a,\u6743\u8c0b'],
    [4, '\u661f\u9645\u8ff7\u822a\u4e4b\u5f52\u9014', '\u6587\u6f9c\u9601\u4e3b', 1, 5, '\u516c\u51433000\u5e74\uff0c\u4eba\u7c7b\u5df2\u7ecf\u8fc8\u5165\u661f\u9645\u65f6\u4ee3\u3002', 'ongoing', 8.9, 1250000, 32100, 4100, '\u79d1\u5e7b,\u661f\u9645,\u5192\u9669'],
    [5, '\u53e4\u5893\u8c1c\u8e2a', '\u4e66\u866b\u5c0f\u674e', 3, 6, '\u8003\u53e4\u7cfb\u6559\u6388\u5e26\u7740\u5b66\u751f\u5728\u6df1\u5c71\u4e2d\u53d1\u73b0\u4e86\u4e00\u5ea7\u795e\u79d8\u53e4\u5893\u3002', 'ongoing', 8.1, 680000, 15200, 1800, '\u60ac\u7591,\u8003\u53e4,\u63a8\u7406'],
    [6, '\u4ed9\u9014\u6f2b\u6f2b', '\u58a8\u9999\u4e66\u7ae5', 2, 2, '\u5728\u4e00\u4e2a\u4fee\u4ed9\u4e16\u754c\u91cc\uff0c\u8d44\u8d28\u5e73\u5e73\u7684\u5c11\u5e74\u51ed\u5019\u575a\u97e7\u4e0d\u62d4\u7684\u610f\u5fd7\u3002', 'ongoing', 7.5, 980000, 12500, 1500, '\u4ed9\u4fa0,\u4fee\u771f,\u6210\u957f'],
    [7, '\u7535\u7ade\u4e4b\u738b', '\u4e66\u866b\u5c0f\u674e', 3, 7, '\u5929\u624d\u5c11\u5e74\u5728\u7535\u7ade\u9886\u57df\u5927\u653e\u5f69\uff0c\u5e26\u9886\u961f\u4f0d\u8d70\u5411\u4e16\u754c\u4e4b\u5dc5\u3002', 'completed', 8.7, 780000, 28900, 3400, '\u7535\u7ade,\u70ed\u8840,\u9752\u6625'],
    [8, '\u82b1\u5f00\u534a\u590f', '\u6587\u6f9c\u9601\u4e3b', 1, 8, '\u4e00\u6bb5\u53d1\u751f\u5728\u6c5f\u5357\u5c0f\u9547\u7684\u7eaf\u7f8e\u7231\u60c5\u6545\u4e8b\u3002', 'completed', 8.3, 450000, 19800, 2600, '\u8a00\u60c5,\u9752\u6625,\u6e29\u99a8']
  ];
  for (const n of novels) await conn.query(
    'INSERT INTO novel (id,title,author,author_id,category_id,description,status,score,word_count,click_count,favorite_count,tags) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)', n
  );
  console.log('Novels inserted:', novels.length);

  // Chapters
  const chapters = [
    [1, 1, '\u7b2c\u4e00\u7ae0 \u661f\u8fb0\u521d\u73b0', '\u5728\u9065\u8fdc\u7684\u5929\u5143\u5927\u9646\u4e0a\uff0c\u6709\u4e00\u4e2a\u53eb\u661f\u8fb0\u9547\u7684\u5c0f\u9547\u3002\n\u5c0f\u9547\u7684\u4e1c\u8fb9\u4f4f\u7740\u4e00\u4e2a\u53eb\u6797\u661f\u7684\u5c11\u5e74\uff0c\u4ed6\u81ea\u7ea6\u7236\u6bcd\u53cc\u4ea1\uff0c\u4e0e\u5e74\u8fc8\u7684\u7237\u7237\u76f8\u4f9d\u4e3a\u547d\u3002', 1, 240],
    [2, 1, '\u7b2c\u4e8c\u7ae0 \u5215\u5165\u5b97\u95e8', '\u4e09\u4e2a\u6708\u540e\uff0c\u661f\u8fb0\u9547\u7684\u5e73\u9759\u88ab\u4e00\u7fa4\u4e0d\u9002\u4e4b\u5ba2\u6253\u7834\u3002', 2, 280],
    [3, 1, '\u7b2c\u4e09\u7ae0 \u661f\u8fb0\u8bc0', '\u8fdb\u5165\u5929\u661f\u5b97\u540e\uff0c\u6797\u661f\u88ab\u5206\u914d\u5230\u4e86\u5916\u95e8\u5f15\u5f80\u5c45\u4f4f\u7684\u9752\u4e91\u9662\u3002', 3, 310],
    [4, 1, '\u7b2c\u56db\u7ae0 \u79d8\u5883\u8bd5\u70bc', '\u4e09\u4e2a\u6708\u540e\uff0c\u5929\u661f\u5b87\u4e3e\u884c\u4e86\u4e00\u5e74\u4e00\u5ea6\u7684\u79d8\u5883\u8bd5\u70bc\u3002', 4, 290]
  ];
  for (const ch of chapters) await conn.query(
    'INSERT INTO novel_chapter (id,novel_id,title,content,chapter_number,word_count) VALUES(?,?,?,?,?,?)', ch
  );
  console.log('Chapters inserted:', chapters.length);

  // Verify
  console.log('\n=== VERIFICATION ===');
  const [users2] = await conn.query('SELECT id, username, nickname FROM novel_user');
  const [cats2] = await conn.query('SELECT id, name FROM novel_category');
  users2.forEach(u => console.log(`User: ${u.username} -> ${u.nickname}`));
  cats2.forEach(c => console.log(`Cat: ${c.id} -> ${c.name}`));

  await conn.end();
  console.log('\nALL DONE!');
}

main().catch(e => { console.error(e); process.exit(1); });
