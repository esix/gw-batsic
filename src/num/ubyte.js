const uhalf = require('./uhalf');

const unpack = (v) => [v.substr(0, 1), v.substr(1, 1)];
const pack = (h, l) => h + l;
const check = (v) => v[2] === undefined && unpack(v).map(uhalf.check).every(Boolean);

function serialize(v) {
  if (!check(v)) throw new Error();
  const [h, l] = unpack(v);
  let ch = uhalf.serialize(h);
  let cl = uhalf.serialize(l);
  let ret = (+ch) * 0x10 + (+cl);
  return String(ret);
}

// function parse(dec) { throw new Error('Not implemented'); }

function inc(v) {
  if (!check(v)) throw new Error();
  let [h, l] = unpack(v), c = '';
  [l, c] = uhalf.inc(l);
  [h, c] = uhalf.addc(h, c);
  return [h + l, c];
}

function addc(v, c) {
  if (!check(v)) throw new Error();
  if (c) [v, c] = inc(v);
  return [v, c];
}

function add(v1, v2) {
  if (!check(v1)) throw new Error();
  if (!check(v2)) throw new Error();
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let [l, cl] = uhalf.add(l1, l2);
  let [h, ch] = uhalf.add(h1, h2);
  [h, c] = uhalf.addc(h, cl);
  return [h + l, ch || c];
}

function mul(v1, v2) {
  if (!check(v1)) throw new Error();
  if (!check(v2)) throw new Error();
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let a1 = '00' + uhalf.mul(l1, l2);
  let [a2, c2] = add(uhalf.mul(l1, h2), uhalf.mul(l2, h1));
  let a3 = uhalf.mul(h1, h2) + '00';
  if (c2) {
    a2 = '1' + a2 + '0';
  } else {
    a2 = '0' + a2 + '0';
  }
  let [r, c_r] = require('./uword').add(a1, a2);
  [r, c_r] = require('./uword').add(r, a3);
  return r;
}

module.exports = {unpack, pack, check, /*serialize,*/ /*parse,*/ inc, addc, add, mul};

