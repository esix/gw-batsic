const uhalf = require('./uhalf');

const dnc = (v) => [v.substr(0, 1), v.substr(1, 1)];

const check = (v) => v[2] === undefined && uhalf.check(v.substr(0, 1)) && uhalf.check(v.substr(1, 1));

function toDec(hex) {
  let ret = '';
  if (!hex[1]) throw new Error();
  if (hex[2]) throw new Error();
  let ch = uhalf.toDec(hex.slice(0, 1));
  let cl = uhalf.toDec(hex.slice(1, 2));
  ret = (+ch) * 16 + (+cl);
  return String(ret);
}

function inc(v) {
  if (!check(v)) throw new Error();
  let [h, l] = dnc(v), c = '';
  [l, c] = uhalf.inc(l);
  [h, c] = uhalf.addc(h, c);
  return [h + l, c];
}

function add(v1, v2) {
  if (!check(v1)) throw new Error();
  if (!check(v2)) throw new Error();
  let [h1, l1] = dnc(v1), [h2, l2] = dnc(v2), c = '';
  let [l, cl] = uhalf.add(l1, l2);
  let [h, ch] = uhalf.add(h1, h2);
  [h, c] = uhalf.addc(h, cl);
  return [h, ch || c];
}

console.log(add('00', '00'))

module.exports = {toDec, inc};

