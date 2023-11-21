const xdword = require("./_xdword");

/**
 * Check if value is a valid QWORD
 * @param {any} v
 * @returns {boolean}
 */
function check(v) {
  return typeof v === 'string' && v.length === 16 && xdword.check(v.substr(0, 8)) && xdword.check(v.substr(8, 8));
}

const checkDec = (n) => {
  // TODO
  return true;
}


const unpack = (v) => [v.substr(0, 8), v.substr(8, 8)];

function pack(h, l) {
  if (!xdword.check(h)) throw 1;
  if (!xdword.check(l)) throw 1;
  return h + l;
}

function toBin(v) {
  if (!check(v)) throw 1;
  let [h, l] = unpack(v);
  return xdword.toBin(h) + xdword.toBin(l);
}


function fromBin(b) {
  // TODO: check 64 bits
  return pack(xdword.fromBin(b.substr(0, 32)), xdword.fromBin(b.substr(32, 32)));
}



/**
 * Shift right
 * @param {string} v
 * @param {string} n
 * @returns {string}
 */
function shr(v, n) {
  if (!check(v)) throw 1;
  if (!checkDec(n)) throw 1;
  let b = toBin(v);
  for (let i = 0; i < +n; i++) b = '0' + b;
  b = b.substr(0, 64);
  return fromBin(b)
}


/**
 * Adds two unsigned
 * @param v1
 * @param v2
 * @returns {[string, '1' | '']}
 */
function add(v1, v2) {
  if (!check(v1)) throw 1;
  if (!check(v2)) throw 1;
  let [h1, l1] = unpack(v1), [h2, l2] = unpack(v2), c = '';
  let [l, cl] = xdword.add(l1, l2);
  let [h, ch] = xdword.add(h1, h2);
  [h, c] = xdword.addc(h, cl);
  return [h + l, ch || c];
}

module.exports = {shr, add};
