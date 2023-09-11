const hex = require("../char/hex");

function parse(hexStr) {
  let state = 'Start';
  let sign = '';

  for (let i = 0; i < hexStr.length; i += 2) {
    let c = hexStr.substr(i, 2);
    const isDigit = hex.isDigit(c);
    const isMinus = hex.isMinus(c);

    if (state === 'Start') {

    }
  }
  return 'INT_0000';
}

module.exports = {parse};
