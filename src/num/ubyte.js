const uhalf = require('./uhalf');


function toDec(hex) {
  let ret = '';
  if (!hex[1]) throw new Error();
  if (hex[2]) throw new Error();
  let ch = uhalf.toDec(hex.slice(0, 1));
  let cl = uhalf.toDec(hex.slice(1, 2));
  ret = (+ch) * 16 + (+cl);
  return String(ret);
}


module.exports = {toDec};

