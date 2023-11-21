const xword = require("./_xword");

const unpack = (v) => [v.substr(0, 4), v.substr(4, 4)];
const pack = (h, l) => h + l;

/**
 * Check if value is a valid DWORD
 * @param {any} v
 * @returns {boolean}
 */
function check(v) {
  return typeof v === 'string' && v.length === 8 && xword.check(v.substr(0, 4)) && xword.check(v.substr(4, 4));
}

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
  return pack(xword.fromBin(b.substr(0, 16)), xword.fromBin(b.substr(16, 16)));
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

/**
 * Shift right
 * @param {string} v
 * @param {string} n
 * @returns {string}
 */
function shr(v, n) {
  if (!check(v)) throw 1;
  if (!checkDec(n)) throw 1;
  let b = toBin(v);
  for (let i = 0; i < +n; i++) b = '0' + b;
  b = b.substr(0, 32);
  return fromBin(b)
}

/**
 * Shift left
 * @param {string} v
 * @param {string} n
 * @returns {string}
 */
function shl(v, n) {
  if (!check(v)) throw 1;
  if (!checkDec(n)) throw 1;
  let b = toBin(v);
  for (let i = 0; i < +n; i++) b = b + '0';
  b = b.substr(n);
  return fromBin(b);
}


function bsr(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v);
  let bsrh = xword.bsr(h);
  if (bsrh !== '0') return String(16 + +bsrh);
  return xword.bsr(l);
}

/**
 *
 * @param {string} v1
 * @param {string} v2
 * @returns {string}
 */
function mul(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let a1 = "00000000" + xword.mul(l1, l2);
  let [a2, c2] = add(xword.mul(l1, h2), xword.mul(l2, h1));
  let a3 = xword.mul(h1, h2) + "00000000";
  if (c2) {
    a2 = "0001" + a2 + "0000";
  } else {
    a2 = "0000" + a2 + "0000";
  }
  let [r, c_r] = require('./_xqword').add(a1, a2);
  [r, c_r] = require('./_xqword').add(r, a3);
  return r;
}

module.exports = {unpack, pack, check, toBin, fromBin, lt, inc, dec, addc, subc, add, sub, shr, shl, bsr, mul};
