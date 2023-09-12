const hex = require("../char/hex");

function parseHexStr(hexStr) {
  let state = 'Start';
  let sign = '';
  let a1 = '';
  let c = '';
  let isDigit = '', isMinus = '', isEOL = '';


  function onStateStart() {
    if (isDigit) {
      a1 += hex.chr(c);
      state = 'Num1';
    } else if (isMinus) {
      sign = '-';
      state = 'Num1';
    } else {
      throw 1;
    }
  }

  function onStateNum1() {
    if (isDigit) {
      a1 += hex.chr(c);
      state = 'Num1';
    } else if (isEOL) {
      state = 'End';
    }
  }

  for (let i = 0; i <= hexStr.length; i += 2) {
    c = hexStr.substr(i, 2) || '00';
    isDigit = hex.isDigit(c);
    isMinus = hex.isMinus(c);
    isEOL = (c === '00');
    if (state === 'Start') onStateStart();
    else if (state === 'Num1') onStateNum1();
  }

  if (state !== 'End') throw 1;


  return 'INT_' + a1;
}

function parse(str) {
  return parseHexStr(str.split('').map(c => c.charCodeAt(0).toString(16).toUpperCase().padStart(2, '0')).join(''));
}

module.exports = {parse};
