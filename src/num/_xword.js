const xbyte = require('./_xbyte');

const unpack = (v) => [v.substr(0, 2), v.substr(2, 2)];
const pack = (h, l) => h + l;
const check = (v) => v[4] === undefined && unpack(v).map(xbyte.check).every(Boolean);

// function serialize(v) {
//   if (!check(v)) throw new Error();
//   const [h, l] = unpack(v);
//   let ch = ubyte.serialize(h);
//   let cl = ubyte.serialize(l);
//   let ret = (+ch) * 0x100 + (+cl);
//   return String(ret);
// }

// function parse(dec) { throw new Error('Not implemented'); }


function lt(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2);
  if (xbyte.lt(h1, h2)) return '1';
  if (xbyte.lt(h2, h1)) return '';
  return xbyte.lt(l1, l2);
}


function inc(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v), c = '';
  [l, c] = xbyte.inc(l);
  [h, c] = xbyte.addc(h, c);
  return [h + l, c];
}

function addc(v, c) {
  if (!check(v)) throw 1;
  if (c) [v, c] = inc(v);
  return [v, c];
}

function add(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let [l, cl] = xbyte.add(l1, l2);
  let [h, ch] = xbyte.add(h1, h2);
  [h, c] = xbyte.addc(h, cl);
  return [h + l, ch || c];
}

function mul(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let a1 = '0000' + xbyte.mul(l1, l2);
  let [a2, c2] = add(xbyte.mul(l1, h2), xbyte.mul(l2, h1));
  let a3 = xbyte.mul(h1, h2) + '0000';
  if (c2) {
    a2 = '01' + a2 + '00';
  } else {
    a2 = '00' + a2 + '00';
  }
  let [r, c_r] = require('./_xdword').add(a1, a2);
  [r, c_r] = require('./_xdword').add(r, a3);
  return r;
}

module.exports = {unpack, pack, check, /*serialize,*/ /*parse,*/ lt, inc, addc, add, mul};
