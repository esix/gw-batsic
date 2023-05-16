
const toBytes = (n) => {
  const a = (n & 0x000000ff) >> 0;
  const b = (n & 0x0000ff00) >> 8;
  const c = (n & 0x00ff0000) >> 16;
  const d = (n & 0xff000000) >> 24;
  return [a, b, c, d];
}

const toSME = (n) => {
  const [a, b, c, d] = toBytes(n);
  if (a === 0) return {sign: 0, mantissa: 0, exponent: 0};
  const exponent = a - 0x80;
  const sign = (b & 0x80) >> 7;
  return {sign: sign ? -1 : 1, mantissa: ((b & 0x7f) << 16) | (c << 8) | (d), exponent};
}


const toBinaryString = (n) => {
  const {sign, mantissa, exponent} = toSME(n);
  return `${sign === 1 ? '+' : '-'}0.1${mantissa.toString(2)} * 2^${exponent}`
}


// 0x00000081  1
// 0x00000082  2
// 0x00004082  3
// 0x00000080  0.5
// 0x00004081  1.5
// 0x00002082  2.5
const n = 0x00002082; // 3
console.log(toBinaryString(n));
