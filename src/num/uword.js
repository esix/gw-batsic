const ubyte = require('./ubyte');

const unpack = (v) => [v.substr(0, 2), v.substr(2, 2)];
const pack = (h, l) => h + l;
const check = (v) => v[4] === undefined && unpack(v).map(ubyte.check).every(Boolean);

// function serialize(v) {
//   if (!check(v)) throw new Error();
//   const [h, l] = unpack(v);
//   let ch = ubyte.serialize(h);
//   let cl = ubyte.serialize(l);
//   let ret = (+ch) * 0x100 + (+cl);
//   return String(ret);
// }

// function parse(dec) { throw new Error('Not implemented'); }

function inc(v) {
  if (!check(v)) throw new Error();
  let [h, l] = unpack(v), c = '';
  [l, c] = ubyte.inc(l);
  [h, c] = ubyte.addc(h, c);
  return [h + l, c];
}

function addc(v, c) {
  if (!check(v)) throw new Error();
  if (c) [v, c] = inc(v);
  return [v, c];
}

function add(v1, v2) {
  if (!check(v1)) throw new Error();
  if (!check(v2)) throw new Error();
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let [l, cl] = ubyte.add(l1, l2);
  let [h, ch] = ubyte.add(h1, h2);
  [h, c] = ubyte.addc(h, cl);
  return [h + l, ch || c];
}

function mul(v1, v2) {
  if (!check(v1)) throw new Error();
  if (!check(v2)) throw new Error();
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let a1 = '0000' + ubyte.mul(l1, l2);
  let [a2, c2] = add(ubyte.mul(l1, h2), ubyte.mul(l2, h1));
  let a3 = ubyte.mul(h1, h2) + '0000';
  if (c2) {
    a2 = '01' + a2 + '00';
  } else {
    a2 = '00' + a2 + '00';
  }
  let [r, c_r] = require('./udword').add(a1, a2);
  [r, c_r] = require('./udword').add(r, a3);
  return r;
}

module.exports = {unpack, pack, check, /*serialize,*/ /*parse,*/ inc, addc, add, mul};
