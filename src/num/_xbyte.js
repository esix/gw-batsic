const xhalf = require('./_xhalf');

const check = (v) => typeof v === 'string' && v.length === 2 && xhalf.check(v.substr(0, 1)) && xhalf.check(v.substr(1, 1));

function unpack(v) {
  if (!check(v)) throw 1;
  return [v.substr(0, 1), v.substr(1, 1)];
}

function pack(h, l) {
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

/**
 * parse decimal from '-128' to '255' and return unsigned
 * 162%
 * hex: &H76
 * oct: &O34, &34
 * @param dec
 */
function parse(dec) {
  let result = "00";
  /** @type {""|"1"} */
  let cf = "";
  for (let i = 0; i < dec.length; i++) {
    let c = dec.substr(i, 1);
    if ("0" <= c && c <= "9") {
      result = mul(result, "0A");
      if (result.slice(0, 2) !== "00") throw 1;
      result = result.slice(2);
      [result, cf] = add("0" + c, result);
      if (cf === "1") throw 1;
    } else {
      throw 1;
    }
  }
  return result;
}

function lt(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2);
  if (xhalf.lt(h1, h2)) return "1";
  if (xhalf.lt(h2, h1)) return "";
  return xhalf.lt(l1, l2);
}


function inc(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v), c = "";
  [l, c] = xhalf.inc(l);
  [h, c] = xhalf.addc(h, c);
  return [h + l, c];
}

function dec(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v), c = "";
  [l, c] = xhalf.dec(l);
  [h, c] = xhalf.subc(h, c);
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
 *
 * @param v1
 * @param v2
 * @returns {[string, ""|"1"]}
 */
function add(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2);
  /** @type {""|"1"} */
  let c = '';
  let [l, cl] = xhalf.add(l1, l2);
  let [h, ch] = xhalf.add(h1, h2);
  [h, c] = xhalf.addc(h, cl);
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
  let [l, cl] = xhalf.sub(l1, l2);
  let [h, ch] = xhalf.sub(h1, h2);
  [h, c] = xhalf.subc(h, cl)
  return [h + l, ch || c]
}

/**
 *
 * @param v1
 * @param v2
 * @returns {string}
 */
function mul(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2);
  let a1 = "00" + xhalf.mul(l1, l2);
  let [a2, c2] = add(xhalf.mul(l1, h2), xhalf.mul(l2, h1));
  let a3 = xhalf.mul(h1, h2) + '00';
  if (c2) {
    a2 = "1" + a2 + "0"
  } else {
    a2 = "0" + a2 + "0";
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
 * @returns {"" | "1"}
 */
function isNegative(sv) {
  if (!check(sv)) throw 1;
  const bin = toBin(sv);
  if (bin.substr(0, 1) === "1") return "1";
  return "";
}

/**
 * Return "1" if first argument is less then second, signed comparision
 * otherwise return ""
 * @param v1
 * @param v2
 * @returns {"" | "1"}
 */
function slt(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  const nv1 = isNegative(v1);
  const nv2 = isNegative(v2);
  if (nv1 === "1" && nv2 === "") return "1";
  if (nv1 === "" && nv2 === "1") return "";
  return lt(v1, v2);
}

function bsr(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v);
  let bsrh = xhalf.bsr(h);
  if (bsrh !== '0') return String(4 + +bsrh);
  return xhalf.bsr(l);
}


module.exports = {unpack, pack, check, /*serialize,*/ parse, lt, inc, dec, addc, subc, add, sub, mul, toBin, fromBin, and, or,
  not, neg, shl, shr, isNegative, slt, bsr};

