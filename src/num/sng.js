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
  const S = sign === '1' ? -1 : 1;
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


function serialize(v) {
  let {Z, S, E, M} = unpack(v);
  M = parseInt(M, 16);
  E = parseInt(E, 16);

  return String(Z ? 0 : S * M * 2 ** (E - 24));
}

module.exports = {serialize};
