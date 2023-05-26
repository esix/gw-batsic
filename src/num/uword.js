const ubyte = require('./ubyte');

const unpack = (v) => [v.substr(0, 2), v.substr(2, 2)];
const pack = (h, l) => h + l;
const check = (v) => v[4] === undefined && unpack(v).map(ubyte.check).every(Boolean);

function serialize(v) {
  if (!check(v)) throw new Error();
  const [h, l] = unpack(v);
  let ch = ubyte.serialize(h);
  let cl = ubyte.serialize(l);
  let ret = (+ch) * 16 * 16 + (+cl);
  return String(ret);
}

function parse(dec) { throw new Error('Not implemented'); }

function inc(v) { throw new Error('Not implemented'); }

function add(v1, v2) {
  if (!check(v1)) throw new Error();
  if (!check(v2)) throw new Error();
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let [l, cl] = ubyte.add(l1, l2);
  let [h, ch] = ubyte.add(h1, h2);
  [h, c] = ubyte.addc(h, cl);
  return [h + l, ch || c];
}

module.exports = {unpack, pack, check, serialize, parse, inc, add};
