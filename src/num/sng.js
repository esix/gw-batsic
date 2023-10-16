const ubyte = require("./_ubyte");

const unpack = (v) => {
  let a = v.substr(0, 2);
  let b = v.substr(2, 2);
  let c = v.substr(4, 2);
  let d = v.substr(6, 2);

  if (a === "00") return {Z: 1, S: 0, E: 0, M: 0 /*, sign: 0, mantissa: 0, exponent: 0*/};

  let [E, _] = ubyte.sub(a, "80");

  const sign = ubyte.toBin(b).substr(0, 1);
  const Z = "";
  const S = sign === '1' ? "-1" : "1";
  let M = '00' + ubyte.or(b, "80") + c + d;
  return { Z, S, E, M };
}

const fromJSFloat = (f) => {
  let e = 0, s = 1;
  if (f === 0) return 0x00000000;
  if (f < 0) { s = -1; f = -f}
  while (f > 1) { f /= 2; e++}
  while (f < 0.5) { f *= 2; e--}
  f -= 0.5;
  f *= 2**24;
  f = f & 0x7fffff;
  return (((e + 0x80) & 0xff) << 24);
};


const log_10_2 = 0.30102999566398;
const ln_10 = 2.30258509299;

function serialize(v) {
  let {Z, S, E, M} = unpack(v);
  if (Z) return 0;
  // S * M * 2 ** (E - 24)
  S = parseInt(S);
  M = parseInt(M, 16);
  E = parseInt(E, 16);

  let e1 = (E - 24) * log_10_2;
  let n = Math.floor(e1);
  let r = e1 - n;
  let x = Math.exp(r * ln_10);        // 10 ** r

  console.log(S, M, E, ' ---> ', M * x, '* 10^');

  return String(S * M * x * 10 ** n);
}

module.exports = {serialize};
