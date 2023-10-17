const xhalf = require('./_xhalf');

const unpack = (v) => [v.substr(0, 1), v.substr(1, 1)];
const pack = (h, l) => String(h) + String(l);
const check = (v) => typeof v === 'string' && v[2] === undefined && unpack(v).map(xhalf.check).every(Boolean);

function serialize(v) {
  if (!check(v)) throw 1;
  const [h, l] = unpack(v);
  let ch = xhalf.serialize(h);
  let cl = xhalf.serialize(l);
  let ret = (+ch) * 0x10 + (+cl);
  return String(ret);
}

// function parse(dec) { throw new Error('Not implemented'); }

function inc(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v), c = '';
  [l, c] = xhalf.inc(l);
  [h, c] = xhalf.addc(h, c);
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
  let [l, cl] = xhalf.add(l1, l2);
  let [h, ch] = xhalf.add(h1, h2);
  [h, c] = xhalf.addc(h, cl);
  return [h + l, ch || c];
}

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


module.exports = {unpack, pack, check, /*serialize,*/ /*parse,*/ inc, addc, add, sub, mul, toBin, and, or, slt};

