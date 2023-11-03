const xhalf = require('./_xhalf');

const check = (v) => {
  if (typeof v !== 'string') return false;
  if (v[2] !== undefined) return false;
  if (!xhalf.check(v.substr(0, 1))) return false;
  if (!xhalf.check(v.substr(1, 1))) return false;
  return true;
}

const unpack = (v) => {
  if (!check(v)) throw 1;
  return [v.substr(0, 1), v.substr(1, 1)];
};

const pack = (h, l) => {
  if (!xhalf.check(h)) throw 1;
  if (!xhalf.check(l)) throw 1;
  return String(h) + String(l);
}

function serialize(v) {
  if (!check(v)) throw 1;
  const [h, l] = unpack(v);
  let ch = xhalf.serialize(h);
  let cl = xhalf.serialize(l);
  let ret = (+ch) * 0x10 + (+cl);
  return String(ret);
}

// function parse(dec) { throw new Error('Not implemented'); }

function lt(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2);
  if (xhalf.lt(h1, h2)) return '1';
  if (xhalf.lt(h2, h1)) return '';
  return xhalf.lt(l1, l2);
}


function inc(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v), c = '';
  [l, c] = xhalf.inc(l);
  [h, c] = xhalf.addc(h, c);
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
  let [l, cl] = xhalf.add(l1, l2);
  let [h, ch] = xhalf.add(h1, h2);
  [h, c] = xhalf.addc(h, cl);
  return [h + l, ch || c];
}

/**
 *
 * @param v1
 * @param v2
 * @returns {[string, '' | '1']}
 */
function sub(v1, v2) {
  if (!check(v1)) throw new Error(`Sub with bad arg ${JSON.stringify(v1)}`);
  if (!check(v2)) throw new Error(`Sub with bad arg ${JSON.stringify(v2)}`);
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let [l, cl] = xhalf.sub(l1, l2);
  let [h, ch] = xhalf.sub(h1, h2);
  [h, c] = xhalf.subc(h, cl)
  return [h + l, ch || c]
}

function mul(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let a1 = '00' + xhalf.mul(l1, l2);
  let [a2, c2] = add(xhalf.mul(l1, h2), xhalf.mul(l2, h1));
  let a3 = xhalf.mul(h1, h2) + '00';
  if (c2) {
    a2 = '1' + a2 + '0';
  } else {
    a2 = '0' + a2 + '0';
  }
  let [r, c_r] = require('./_xword').add(a1, a2);
  [r, c_r] = require('./_xword').add(r, a3);
  return r;
}

function toBin(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v);
  return xhalf.toBin(h) + xhalf.toBin(l);
}

function fromBin(b) {
  // TODO: check 8 bits
  return xhalf.fromBin(b.substr(0, 4)) + xhalf.fromBin(b.substr(4, 4));
}

function and(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2);
  return pack(xhalf.and(h1, h2), xhalf.and(l1, l2));
}

function or(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2);
  return pack(xhalf.or(h1, h2), xhalf.or(l1, l2));
}

function not(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v);
  return pack(xhalf.not(h), xhalf.not(l));
}

function shl(v, n) {
  if (!check(v)) throw 1;
  let b = toBin(v);
  for (let i = 0; i < +n; i++) b = b + '0';
  b = b.substr(+n);
  return fromBin(b);
}

function shr(v, n) {
  if (!check(v)) throw 1;
  let b = toBin(v);
  for (let i = 0; i < +n; i++) b = '0' + b;
  b = b.substr(0, 8);
  return fromBin(b)
}

function neg(v) {
  if (!check(v)) throw 1;
  let notv = not(v)
  let [r, c] = add(notv, "01");
  return r;
}

/**
 *
 * @param sv - hex byte
 * @returns {"0" | "1"}
 */
function isNegative(sv) {
  if (!check(sv)) throw 1;
  const bin = toBin(sv);
  if (bin.substr(0, 1) === '1') return '1';
  return '0';
}

/**
 * Return '1' if first argument is less then second, signed comparision
 * otherwise return '0'
 * @param v1
 * @param v2
 * @returns {"0" | "1"}
 */
function slt(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  const nv1 = isNegative(v1);
  const nv2 = isNegative(v2);
  if (nv1 === '1' && nv2 === '0') return '1';
  if (nv1 === '0' && nv2 === '1') return '0';
  if (v1 < v2) return '1';
  return '0';
}


module.exports = {unpack, pack, check, /*serialize,*/ /*parse,*/ lt, inc, addc, add, sub, mul, toBin, fromBin, and, or, not, neg, shl, shr, isNegative, slt};

