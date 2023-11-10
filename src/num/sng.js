const xbyte = require("./_xbyte");
const xdword = require("./_xdword");

function unpack(v) {
  let a = v.substr(0, 2);
  let b = v.substr(2, 2);
  let c = v.substr(4, 2);
  let d = v.substr(6, 2);

  if (a === "00") return {S: "0", E: "00", M: "00000000"};  /*, sign: 0, mantissa: 0, exponent: 0*/

  let [E, _] = xbyte.sub(a, "80");

  const sign = xbyte.toBin(b).substr(0, 1);
  const S = sign === '1' ? "-1" : "1";
  // ??
  let M = '00' + xbyte.or(b, "80") + c + d;
  return { S, E, M };
}

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
  return sign === '1';
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


// compare absolute values
function _lt(v1, v2) {
  let {S: S1, E: E1, M: M1} = unpack(v1);
  let {S: S2, E: E2, M: M2} = unpack(v1);
  if (xbyte.lt(E1, E2)) return '1';
  if (xbyte.lt(E2, E1)) return '';
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
    else return '1';
  } else {
    if (isNegative(v2)) return '';
    else return _lt(v1, v2);
  }
}



// ignore sign bits
function _add(v1, v2) {
  if (_lt(v2, v1)) {                          // ] v₁ <= v₂
    [v1, v2] = [v2, v1];
  }
  let de, M, c;
  // TODO ...
  let {S: S1, E: E1, M: M1} = unpack(v1);
  let {S: S2, E: E2, M: M2} = unpack(v2);
  // E₁ ≤ E₂
  // M₁⋅2ᴱ¹⁻²⁴ + M₂⋅2ᴱ²⁻²⁴ = (M₁⋅2ᴱ¹⁻ᴱ² + M₂)⋅2ᵉ²⁻²⁴ = (M₁/2ᴱ²⁻ᴱ¹ + M₂)⋅2ᴱ²⁻²⁴
  [de, c] = xbyte.sub(E2, E1);
  M1 = xdword.shr(M1, de);
  [M, c] = xdword.add(M1, M2);
  if (M === "00000000") return "00000000";
  let hb = xdword.bsr(M);
  if (+hb < 24) {    // hb < 24
    throw 100;
  }
  if (24 < +hb) {     // hb > 24
    M = xdword.shr(M, String(hb - 24));
    [E2, c] = xbyte.add(E2, xbyte.parse(String(hb - 24)));
  }
  return pack('1', E2, M);
}

// ignore sign bits
function _sub(v1, v2) {
  //
}


function add(v1, v2) {
  if (isZero(v1)) return v2;
  if (isZero(v2)) return v1;
  if (isNegative(v1)) {
    if (isNegative(v2)) return neg(_add(v1, v2));
    else return _sub(v2, v1);
  } else {
    if (isNegative(v2)) return _sub(v1, v2);
    else return _add(v2, v1);
  }
}



const log_10_2 = 0.30102999566398;
const ln_10 = 2.30258509299;

function serialize(v) {
  let {S, E, M} = unpack(v);
  if (S === "0") return "0";
  // S * M * 2^(E - 24)
  S = parseInt(S);
  M = parseInt(M, 16);
  E = parseInt(E, 16);

  let e1 = (E - 24) * log_10_2;                           // v = S⋅M⋅10ᵉ¹
  let n = Math.floor(e1);                                 // e₁ = n + r,  n = ⌊e₁⌋
  let r = e1 - n;                                         // v = S⋅M⋅10ʳ⋅10ⁿ
  let x = Math.exp(r * ln_10);                            // x = 10ʳ

  console.log(S, M, E, ' ---> ', M * x, '* 10^' + String(n));

  return String(S * M * x * 10 ** n);
}

module.exports = {unpack, pack, fromSB, serialize, lt, neg, add};
