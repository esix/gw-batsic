const xword = require('./_xword');

const unpack = (v) => [v.substr(0, 4), v.substr(4, 4)];
const pack = (h, l) => h + l;
const check = (v) => v[8] === undefined && unpack(v).map(xword.check).every(Boolean);

const checkDec = (n) => {
  // TODO
  return true;
}

function toBin(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v);
  return xword.toBin(h) + xword.toBin(l);
}

function fromBin(b) {
  // TODO: check 32 bits
  return xword.fromBin(b.substr(0, 16)) + xword.fromBin(b.substr(16, 16));
}

function lt(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2);
  if (xword.lt(h1, h2)) return '1';
  if (xword.lt(h2, h1)) return '';
  return xword.lt(l1, l2);
}

function inc(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v), c = '';
  [l, c] = xword.inc(l);
  [h, c] = xword.addc(h, c);
  return [h + l, c];
}

function dec(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v), c = "";
  [l, c] = xword.dec(l);
  [h, c] = xword.subc(h, c);
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

/**
 * Adds two unsigned
 * @param v1
 * @param v2
 * @returns {[string, '1' | '']}
 */
function add(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let [l, cl] = xword.add(l1, l2);
  let [h, ch] = xword.add(h1, h2);
  [h, c] = xword.addc(h, cl);
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
  let [l, cl] = xword.sub(l1, l2);
  let [h, ch] = xword.sub(h1, h2);
  [h, c] = xword.subc(h, cl)
  return [h + l, ch || c]
}


function shr(v, n) {
  if (!check(v)) throw 1;
  if (!checkDec(n)) throw 1;
  let b = toBin(v);
  for (let i = 0; i < +n; i++) b = '0' + b;
  b = b.substr(0, 32);
  return fromBin(b)
}

function bsr(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v);
  let bsrh = xword.bsr(h);
  if (bsrh !== '0') return String(16 + +bsrh);
  return xword.bsr(l);
}


module.exports = {unpack, pack, check, lt, inc, dec, addc, subc, add, sub, shr, bsr};