
function check(v) {
  return v.length === 1 && ((v >= '0' && v <= '9') || (v >= 'A' && v <= 'F'));
}

function serialize(v) {
  if (!check(v)) throw new Error();
  let ret = '';
  if (v === '0') ret = '0';
  if (v === '1') ret = '1';
  if (v === '2') ret = '2';
  if (v === '3') ret = '3';
  if (v === '4') ret = '4';
  if (v === '5') ret = '5';
  if (v === '6') ret = '6';
  if (v === '7') ret = '7';
  if (v === '8') ret = '8';
  if (v === '9') ret = '9';
  if (v === 'A') ret = '10';
  if (v === 'B') ret = '11';
  if (v === 'C') ret = '12';
  if (v === 'D') ret = '13';
  if (v === 'E') ret = '14';
  if (v === 'F') ret = '15';

  if (ret === '') throw new Error();
  return ret;
}

function parse(dec) {
  let ret = '';
  if (dec === '0') ret = '0';
  if (dec === '1') ret = '1';
  if (dec === '2') ret = '2';
  if (dec === '3') ret = '3';
  if (dec === '4') ret = '4';
  if (dec === '5') ret = '5';
  if (dec === '6') ret = '6';
  if (dec === '7') ret = '7';
  if (dec === '8') ret = '8';
  if (dec === '9') ret = '9';
  if (dec === '10') ret = 'A';
  if (dec === '11') ret = 'B';
  if (dec === '12') ret = 'C';
  if (dec === '13') ret = 'D';
  if (dec === '14') ret = 'E';
  if (dec === '15') ret = 'F';

  if (ret === '') throw new Error(`uhalf: parse '${dec}' error`);
  return ret;
}

function lt(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  if (v1 < v2) return '1';
  return '';
}

function inc(v) {
  if (!check(v)) throw 1;
  let d = serialize(v), c = '';
  d = String((+d) + 1);
  if (d === '16') {
    d = '0';
    c = '1';
  }
  v = parse(d);
  return [v, c];
}

function dec(v) {
  if (!check(v)) throw 1;
  let d = serialize(v), c = '';
  d = String((+d) - 1);
  if (d === '-1') {
    d = '15';
    c = '1';
  }
  v = parse(d);
  return [v, c];
}

function addc(v, c) {
  if (!check(v)) throw 1;
  if (c) [v, c] = inc(v);
  return [v, c];
}

function add(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let d1 = serialize(v1), d2 = serialize(v2), c = '';
  let d = String((+d1) + (+d2));
  if ((+d) >= 16) { d = String((+d) - 16); c = '1';}
  let v = parse(d);
  return [v, c];
}

function subc(v, c) {
  if (!check(v)) throw 1;
  if (c) [v, c] = dec(v);
  return [v, c];
}

function sub(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let d1 = serialize(v1), d2 = serialize(v2), c = '';
  let d = String((+d1) - (+d2));
  if ((+d) < 0) { d = String((+d) + 16); c = '1';}
  let v = parse(d);
  return [v, c];
}

function mul(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let d1 = serialize(v1), d2 = serialize(v2), c = '';
  let d = String((+d1) * (+d2));
  let h = parse(String(Math.floor((+d) / 16))), l = parse(String((+d) % 16));
  return `${h}${l}`;
}

function toBin(v) {
  let ret = '';
  if (!check(v)) throw 1;
  if (v === '0') ret = '0000';
  if (v === '1') ret = '0001';
  if (v === '2') ret = '0010';
  if (v === '3') ret = '0011';
  if (v === '4') ret = '0100';
  if (v === '5') ret = '0101';
  if (v === '6') ret = '0110';
  if (v === '7') ret = '0111';
  if (v === '8') ret = '1000';
  if (v === '9') ret = '1001';
  if (v === 'A') ret = '1010';
  if (v === 'B') ret = '1011';
  if (v === 'C') ret = '1100';
  if (v === 'D') ret = '1101';
  if (v === 'E') ret = '1110';
  if (v === 'F') ret = '1111';
  return ret;
}

function fromBin(b) {
  let ret = '';
  if (b === '0000') ret = '0';
  if (b === '0001') ret = '1';
  if (b === '0010') ret = '2';
  if (b === '0011') ret = '3';
  if (b === '0100') ret = '4';
  if (b === '0101') ret = '5';
  if (b === '0110') ret = '6';
  if (b === '0111') ret = '7';
  if (b === '1000') ret = '8';
  if (b === '1001') ret = '9';
  if (b === '1010') ret = 'A';
  if (b === '1011') ret = 'B';
  if (b === '1100') ret = 'C';
  if (b === '1101') ret = 'D';
  if (b === '1110') ret = 'E';
  if (b === '1111') ret = 'F';
  return ret;
}

function not(v) {
  if (!check(v)) throw 1;
  let bin = toBin(v);
  let r = '';
  if (bin.substr(0, 1) === '1') r += '0'; else r += '1';
  if (bin.substr(1, 1) === '1') r += '0'; else r += '1';
  if (bin.substr(2, 1) === '1') r += '0'; else r += '1';
  if (bin.substr(3, 1) === '1') r += '0'; else r += '1';
  return fromBin(r);
}

function binAnd(b1, b2) {
  if (b1 === '1' && b2 === '1') return '1';
  return '0';
}

function binOr(b1, b2) {
  if (b1 === '1' || b2 === '1') return '1';
  return '0';
}

function and(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let b1 = toBin(v1), b2 = toBin(v2);
  return fromBin(
      binAnd(b1[0], b2[0]) +
      binAnd(b1[1], b2[1]) +
      binAnd(b1[2], b2[2]) +
      binAnd(b1[3], b2[3]));
}

function or(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let b1 = toBin(v1), b2 = toBin(v2);
  return fromBin(
      binOr(b1[0], b2[0]) +
      binOr(b1[1], b2[1]) +
      binOr(b1[2], b2[2]) +
      binOr(b1[3], b2[3]));
}




module.exports = {check, serialize, parse, lt, inc, dec, addc, add, subc, sub, mul, not, and, or, toBin, fromBin};

