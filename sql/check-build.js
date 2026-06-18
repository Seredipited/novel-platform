const fs = require('fs');
const modules = ['common','ai-service','chapter-service','gateway'];
modules.forEach(m => {
  const p = 'D:/IDEA/ssm/novel-platform/backend/' + m + '/target';
  if (fs.existsSync(p)) {
    const jars = fs.readdirSync(p).filter(x => x.endsWith('.jar'));
    console.log(m + ': OK (' + jars.length + ' jars)');
  } else {
    console.log(m + ': NO TARGET DIR');
  }
});
