const uhalf = require("./_uhalf");


function parseStr(s) {
  let r = '', m = '';
  while ((+s) > 0) {
    m = String((+s) % 16);
    s = String(Math.floor((+s) / 16));
    r = uhalf.parse(m) + r;
  }

  if (!r) r = '0';
  while (r.length < 4) r = '0' + r;
  return r;
}

module.exports = {parseStr};
