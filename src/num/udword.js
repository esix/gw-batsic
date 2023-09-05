const uword = require('./uword');

const unpack = (v) => [v.substr(0, 4), v.substr(4, 4)];
const pack = (h, l) => h + l;
const check = (v) => v[8] === undefined && unpack(v).map(uword.check).every(Boolean);

function inc(v) { throw new Error('Not implemented'); }

function add(v1, v2) {
  if (!check(v1)) throw new Error();
  if (!check(v2)) throw new Error();
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let [l, cl] = uword.add(l1, l2);
  let [h, ch] = uword.add(h1, h2);
  [h, c] = uword.addc(h, cl);
  return [h + l, ch || c];
}

module.exports = {unpack, pack, check, add};
