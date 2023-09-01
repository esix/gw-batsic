
function check(v) {
  return v.length === 1 &&
      ((v >= '0' && v <= '9') || (v >= 'a' && v <= 'f') || (v >= 'A' && v <= 'F'));
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
  if (v === 'a') ret = '10';
  if (v === 'B') ret = '11';
  if (v === 'b') ret = '11';
  if (v === 'C') ret = '12';
  if (v === 'c') ret = '12';
  if (v === 'D') ret = '13';
  if (v === 'd') ret = '13';
  if (v === 'E') ret = '14';
  if (v === 'e') ret = '14';
  if (v === 'F') ret = '15';
  if (v === 'f') ret = '15';

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

function inc(v) {
  if (!check(v)) throw new Error();
  let d = serialize(v), c = '';
  d = String((+d) + 1);
  if (d === '16') {
    d = '0';
    c = '1';
  }
  v = parse(d);
  return [v, c];
}

function addc(v, c) {
  if (!check(v)) throw new Error();
  if (c) [v, c] = inc(v);
  return [v, c];
}

function add(v1, v2) {
  if (!check(v1)) throw new Error();
  if (!check(v2)) throw new Error();
  let d1 = serialize(v1), d2 = serialize(v2), c = '';
  let d = String((+d1) + (+d2));
  if ((+d) >= 16) { d = String((+d) - 16); c = '1';}
  let v = parse(d);
  return [v, c];
}

function mul(v1, v2) {
  if (!check(v1)) throw new Error();
  if (!check(v2)) throw new Error();
  let d1 = serialize(v1), d2 = serialize(v2), c = '';
  let d = String((+d1) * (+d2));
  let h = parse(String(Math.floor((+d) / 16))), l = parse(String((+d) % 16));
  return [h, l];
}

module.exports = {check, serialize, parse, inc, addc, add, mul};

