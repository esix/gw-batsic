const xbyte = require("./_xbyte");
const xdword = require("./_xdword");
const xqword = require("./_xqword");

/**
 *
 * @param {any} v
 * @returns {boolean}
 */
function check(v) {
  return xdword.check(v);
}

/**
 *
 * @param v
 * @returns {{S: "-1"|"0"|"1", E: string, M: string}}
 */
function unpack(v) {
  let a = v.substr(0, 2);
  let b = v.substr(2, 2);
  let c = v.substr(4, 2);
  let d = v.substr(6, 2);

  if (a === "00") return {S: "0", E: "00", M: "00000000"};  /*, sign: 0, mantissa: 0, exponent: 0*/

  let [E, _] = xbyte.sub(a, "80");

  const sign = xbyte.toBin(b).substr(0, 1);
  const S = sign === "1" ? "-1" : "1";
  // ??
  let M = '00' + xbyte.or(b, "80") + c + d;
  return { S, E, M };
}

/**
 *
 * @param {"-1"|"0"|"1"} S
 * @param {string} E
 * @param {string} M
 * @returns {string}
 */
function pack(S, E, M) {
  if (!xbyte.check(E)) throw 1;
  if (!xdword.check(M)) throw 1;
  if (M.slice(0, 2) !== '00') throw 1;
  if (!(S === '-1' || S === '0' || S === '1')) throw 1;
  //
  if (S === '0') return "00000000";
  let [a, _] = xbyte.add(E, "80");
  let b = xbyte.and(M.substr(2, 2), "7F");
  if (S === "-1") b = xbyte.or(b, '80');
  let c = M.substr(4, 2);
  let d = M.substr(4, 2);
  return a + b + c + d;
}

function isZero(v) {
  return v.slice(0, 2) === "00";
}

function isNegative(v) {
  let b = v.substr(2, 2);
  const sign = xbyte.toBin(b).substr(0, 1);
  return sign === '1' ? '1' : '';
}


function fromSB(sb) {
  if (!xbyte.check(sb)) throw 1;
  if (sb === "00") return "00000000";
  let E = '01', S = '1';

  if (xbyte.isNegative(sb) === '1') {
    S = '-1';
    sb = xbyte.neg(sb);
  }

  let bin = xbyte.toBin(sb);
  if (bin[6] === '1') E = '02';
  if (bin[5] === '1') E = '03';
  if (bin[4] === '1') E = '04';
  if (bin[3] === '1') E = '05';
  if (bin[2] === '1') E = '06';
  if (bin[1] === '1') E = '07';
  let M = xbyte.shl(sb, 8 - E);

  return pack(S, E, '00' + M + '0000');
}

function neg(v) {
  let {S, E, M} = unpack(v);
  if (S === '0') return v;
  if (S === '-1') S = '1';
  else S = '-1';
  return pack(S, E, M);
}


/**
 * Compare by absolute value
 * @param {string} v1
 * @param {string} v2
 * @returns {string|string}
 * @private
 */
function _lt(v1, v2) {
  let {S: S1, E: E1, M: M1} = unpack(v1);
  let {S: S2, E: E2, M: M2} = unpack(v2);
  if (xbyte.slt(E1, E2)) return '1';
  if (xbyte.slt(E2, E1)) return '';
  return xdword.lt(M1, M2);
}

/**
 *
 * @param v1
 * @param v2
 * @returns {'1' | ''}
 */
function lt(v1, v2) {
  if (isNegative(v1)) {
    if (isNegative(v2)) return _lt(v2, v1);
    else return "1";
  } else {
    if (isNegative(v2)) return "";
    else return _lt(v1, v2);
  }
}


// ignore sign bits
function _add(v1, v2) {
  // v₁ >= v₂
  let de, M, c;
  let {S: S1, E: E1, M: M1} = unpack(v1);
  let {S: S2, E: E2, M: M2} = unpack(v2);
  // E₁ ≥ E₂
  // M₁⋅2ᴱ¹⁻²⁴ + M₂⋅2ᴱ²⁻²⁴ = (M₁ + M₂⋅2ᴱ²⁻ᴱ¹)⋅2ᴱ¹⁻²⁴ = (M₁ + M₂/2ᴱ¹⁻ᴱ²)⋅2ᴱ¹⁻²⁴
  [de, c] = xbyte.sub(E1, E2);
  M2 = xdword.shr(M2, de);                    // M₂ ￩ M₂/2ᴱ¹⁻ᴱ²
  [M, c] = xdword.add(M1, M2);
  if (M === "00000000") return "00000000";
  let hb = xdword.bsr(M);
  if (+hb < 24) {    // hb < 24
    throw 100;
  }
  if (24 < +hb) {     // hb > 24
    M = xdword.shr(M, String(hb - 24));
    [E1, c] = xbyte.add(E1, xbyte.parse(String(hb - 24)));
  }
  return pack('1', E1, M);
}

// ignore sign bits
function _sub(v1, v2) {
  // v₁ >= v₂
  let de, M, c;
  let {S: S1, E: E1, M: M1} = unpack(v1);
  let {S: S2, E: E2, M: M2} = unpack(v2);
  // M₁⋅2ᴱ¹⁻²⁴ - M₂⋅2ᴱ²⁻²⁴ = (M₁ + M₂⋅2ᴱ²⁻ᴱ¹)⋅2ᴱ¹⁻²⁴ = (M₁ + M₂/2ᴱ¹⁻ᴱ²)⋅2ᴱ¹⁻²⁴
  [de, c] = xbyte.sub(E1, E2);
  M2 = xdword.shr(M2, de);                    // M₂ ￩ M₂/2ᴱ¹⁻ᴱ²
  [M, c] = xdword.sub(M1, M2);
  if (M === "00000000") return "00000000";
  let hb = xdword.bsr(M);
  if (+hb < 24) {    // hb < 24
    M = xdword.shl(M, String(24 - hb));
    [E1, c] = xbyte.sub(E1, xbyte.parse(String(24 - hb)));
  }
  if (24 < +hb) {     // hb > 24
    throw 100;
  }
  return pack('1', E1, M);
}


function add(a, b) {
  if (!check(a)) throw 1;
  if (!check(b)) throw 1;

  if (isZero(a)) return b;
  if (isZero(b)) return a;
  let aGEb = _lt(b, a);                 // |a| >= |b|
  if (isNegative(a)) {
    if (isNegative(b))
      if (aGEb) return neg(_add(a, b));
      else return neg(_add(b, a));
    else
      if (aGEb) return neg(_sub(a, b));
      else return _sub(b, a);
  } else {
    if (!isNegative(b))
      if (aGEb) return _add(a, b);
      else return _add(b, a);
    else
      if (aGEb) return _sub(a, b);
      else return neg(_sub(b, a));
  }
}

function sub(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  return add(v1, neg(v2));
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

  let {S: S1, E: E1, M: M1} = unpack(v1);
  let {S: S2, E: E2, M: M2} = unpack(v2);

  if (S1 === "0") return "00000000";
  if (S2 === "0") return "00000000";

  // M₁⋅2ᴱ¹⁻²⁴ ⋅ M₂⋅2ᴱ²⁻²⁴ = (M₁⋅M₂)⋅2ᴱ¹⁻²⁴⁺ᴱ²⁻²⁴
  let M = xdword.mul(M1, M2);
  M = xqword.shr(M, "24");
  let [E, c] = xbyte.sadd(E1, E2);
  if (c) {
    throw 200;
  }

}


const log_10_2 = 0.30102999566398;
const ln_10 = 2.30258509299;

/**
 *
 * @param {string} v
 * @returns {string}
 */
function serialize(v) {
  let {S, E, M} = unpack(v);
  if (S === "0") return "0";

  S = parseInt(S);
  M = parseInt(M, 16);
  E = parseInt(E, 16);

  let E1 = (E - 24) * log_10_2;                           // v = S⋅M⋅2ᴱ⁻²⁴ = S⋅M⋅10ᴱ¹
  let n = Math.floor(E1);                                 // e₁ = n + r,  n = ⌊e₁⌋
  let r = E1 - n;                                         // v = S⋅M⋅10ʳ⋅10ⁿ
  let x = Math.exp(r * ln_10);                            // x = 10ʳ

  console.log(S, M, E, ' ---> ', M * x, '* 10^' + String(n));

  return String(S * M * x * 10 ** n);
}

module.exports = {unpack, pack, fromSB, serialize, lt, neg, add, sub, mul};
