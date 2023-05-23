const ubyte = require('./ubyte');


function toDec(hex) {
  let ret = '';
  if (!hex[3]) throw new Error();
  if (hex[4]) throw new Error();
  let ch = ubyte.toDec(hex.slice(0, 2));
  let cl = ubyte.toDec(hex.slice(2, 4));
  ret = (+ch) * 256 + (+cl);
  return String(ret);
}


function add(hex1, hex2) {
  let res = '';
}

module.exports = {toDec, add};
