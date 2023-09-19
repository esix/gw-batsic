const hex = require("../chr/hex");
const int = require("./int");

function parseHexStr(xs) {
  let state = 'Start';
  let sign = '';
  let a1 = '';
  let c = '';
  let isDigit = '', isMinus = '', isEOL = '', isZero = '';

  function onStateStart() {
    if (isZero) {                           state = 'Num0'; }
    else if (isDigit) { a1 += hex.chr(c);   state = 'Num1'; }
    else if (isMinus) { sign = '-';         state = 'Num0'; }
    else throw 1;
  }

  function onStateNum0() {
    if (isZero) {}
    else if (isDigit) { a1 += hex.chr(c);   state = 'Num1'; }
    else if (isEOL)   { a1 += '0';          state = 'End';  }
    else throw 1;
  }

  function onStateNum1() {
    if (isDigit)      {  a1 += hex.chr(c);  state = 'Num1'; }
    else if (isEOL)   {                     state = 'End';  }
    else throw 1;
  }

  for (let i = 0; i <= xs.length; i += 2) {
    c = xs.substr(i, 2) || '00';
    isDigit = hex.isDigit(c);
    isMinus = hex.isMinus(c);
    isZero = hex.isZero(c);
    isEOL = (c === '00');
    if (state === 'Start') onStateStart();
    else if (state === 'Num0') onStateNum0();
    else if (state === 'Num1') onStateNum1();
    else throw 1;
  }

  if (state !== 'End') throw 1;

  if (a1.length <= 5) {
    let hex = int.parseStr(a1);
    return 'INT_' + hex;
  }

  return 'SNG_' + a1;
}

function parse(s) {
  return parseHexStr(s.split('').map(c => c.charCodeAt(0).toString(16).toUpperCase().padStart(2, '0')).join(''));
}

module.exports = {parse};
