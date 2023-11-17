const xbyte = require('./_xbyte');

const check = (v) => typeof v === 'string' && v.length === 4 && xbyte.check(v.substr(0, 2)) && xbyte.check(v.substr(2, 2));

function unpack(v) {
  if (!check(v)) throw 1;
  return [v.substr(0, 2), v.substr(2, 2)];
}

function pack(h, l) {
  if (!xbyte.check(h)) throw 1;
  if (!xbyte.check(l)) throw 1;
  return String(h) + String(l);
}

// function serialize(v) {
//   if (!check(v)) throw new Error();
//   const [h, l] = unpack(v);
//   let ch = ubyte.serialize(h);
//   let cl = ubyte.serialize(l);
//   let ret = (+ch) * 0x100 + (+cl);
//   return String(ret);
// }

// function parse(dec) { throw new Error('Not implemented'); }

function toBin(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v);
  return xbyte.toBin(h) + xbyte.toBin(l);
}

function fromBin(b) {
  // TODO: check 16 bits
  return xbyte.fromBin(b.substr(0, 8)) + xbyte.fromBin(b.substr(8, 8));
}


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

function dec(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v), c = "";
  [l, c] = xbyte.dec(l);
  [h, c] = xbyte.subc(h, c);
  return [h + l, c];
}

function addc(v, c) {
  if (!check(v)) throw 1;
  if (c) [v, c] = inc(v);
  return [v, c];
}

function subc(v, c) {
  if (!check(v)) throw 1;
  if (c) [v, c] = dec(v);
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

/**
 * Unsigned subtraction
 * @param v1
 * @param v2
 * @returns {[string, '' | '1']}
 */
function sub(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let [l, cl] = xbyte.sub(l1, l2);
  let [h, ch] = xbyte.sub(h1, h2);
  [h, c] = xbyte.subc(h, cl)
  return [h + l, ch || c]
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


function bsr(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v);
  let bsrh = xbyte.bsr(h);
  if (bsrh !== '0') return String(8 + +bsrh);
  return xbyte.bsr(l);
}


module.exports = {unpack, pack, check, toBin, fromBin, /*serialize,*/ /*parse,*/ lt, inc, dec, addc, subc, add, sub, mul, bsr};
