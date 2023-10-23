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
  // TODO:
  // if (S === "-1") b = xbyte.or()
  let c = M.substr(4, 2);
  let d = M.substr(4, 2);
  return a + b + c + d;
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

function fromSB(sb) {
  if (!xbyte.check(sb)) throw 1;
  if (sb === "00") return "00000000";
  let bin = xbyte.toBin(sb);
  let E = '80';

  if (bin.substr(0, 1) === "1") {   // < 0
    // TODO
  } else {
    if (bin[1] === '1') return '87' + xbyte.add(sb, '') + '0000';
    if (bin[2] === '1') { E = '86'; }
    if (bin[3] === '1') { E = '85'; }
    if (bin[4] === '1') { E = '84'; }
    if (bin[5] === '1') return '83' + xbyte.and(sb, 'FB') + '0000';
    if (bin[6] === '1') return '82' + xbyte.and(sb, 'FD') + '0000';
    if (bin[7] === '1') return '81' + xbyte.and(sb, 'FE') + '0000';
    return E + sb + '0000';
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

  let e1 = (E - 24) * log_10_2;           // v = S * M * 10^e1
  let n = Math.floor(e1);
  let r = e1 - n;                        // v = S * M * 10^r * 10^n
  let x = Math.exp(r * ln_10);        // x = 10^r

  console.log(S, M, E, ' ---> ', M * x, '* 10^');

  return String(S * M * x * 10 ** n);
}

module.exports = {unpack, pack, fromSB, serialize};
