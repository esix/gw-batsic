
const unpack = (n) => {
  const a = n >> 24 & 0xff;
  const b = n >> 16 & 0xff;
  const c = n >> 8  & 0xff;
  const d = n >> 0  & 0xff;
  if (a === 0) return {Z: 1, S: 0, E: 0, M: 0 /*, sign: 0, mantissa: 0, exponent: 0*/};
  const exponent = a - 0x80;
  const sign = (b & 0x80) >> 7;
  const Z = 0;
  const S = sign ? -1 : 1;
  const E = exponent - 24;
  const M = ((b | 0x80) << 16) | (c << 8) | (d << 0);
  return {
    Z,
    S,
    E,
    M,
  };
}

const toJSFloat = (n) => {
  const {Z, S, M, E} = unpack(n);
  return Z ? 0 : S * M * 2 ** E;
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



// 0x81000000  1
// 0x82000000  2
// 0x82400000  3
// 0x80000000  0.5
// 0x81400000  1.5
// 0x82200000  2.5

// console.log('0  ', toJSFloat(0x00FFFFFF));
// console.log('0.5', toJSFloat(0x80000000));
// console.log('1  ', toJSFloat(0x81000000));
// console.log('1.5', toJSFloat(0x81400000));
// console.log('2  ', toJSFloat(0x82000000));
// console.log('2.5', toJSFloat(0x82200000));
// console.log('3  ', toJSFloat(0x82400000));

console.log('1.5', fromJSFloat(1.5).toString(16).padStart(8, '0'));


function serialize(v) {
  let a = v.substr(0, 2);
  let b = v.substr(2, 2);
  let c = v.substr(4, 2);
  let d = v.substr(6, 2);

  if (a === '00') return "0";
  a = parseInt(a, 16);
  b = parseInt(b, 16);
  c = parseInt(c, 16);
  d = parseInt(d, 16);
  const exponent = a - 0x80;
  const sign = (b & 0x80) >> 7;
  const Z = 0;
  const S = sign ? -1 : 1;
  const E = exponent - 24;
  const M = ((b | 0x80) << 16) | (c << 8) | (d << 0);

  return String( Z ? 0 : S * M * 2 ** E);
}

module.exports = {serialize};