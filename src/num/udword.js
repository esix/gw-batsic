const uword = require('./uword');

const unpack = (v) => [v.substr(0, 4), v.substr(2, 4)];
const pack = (h, l) => h + l;
const check = (v) => v[8] === undefined && unpack(v).map(uword.check).every(Boolean);

module.exports = {unpack, pack, check};
