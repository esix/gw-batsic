const hex = require("../chr/hex");

function encode(xs) {
  let c = '';
  let isDigit = '', isMinus = '', isEOL = '', isSpace = '';
  let state = 'Start';

  function stateStart() {
    if (isEOL) return;
    if (isSpace) return;
  }

  function stateNormal() { }
  function stateId() {}
  function stateLineNumber() {
    // < 65530

  }
  function stateNumber0() {}
  function stateNumber1() {}
  function stateNumber2() {}
  function stateLess() {}
  function stateMode() {}
  function stateQuote() {}
  function stateRem() {}


  for (let i = 0; i <= xs.length; i += 2) {
    c = xs.substr(i, 2) || '00';
    isDigit = hex.isDigit(c);
    isMinus = hex.isMinus(c);
    isEOL = (c === '00');
    isSpace = hex.isSpace(c);

    if (state === 'Start') stateStart();
    else if (state === 'Normal') stateNormal();
    else if (state === 'Id') stateId();
    else if (state === 'LineNumber') stateLineNumber();
    else if (state === 'Number0') stateNumber0();
    else if (state === 'Number1') stateNumber1();
    else if (state === 'Number2') stateNumber2();
    else if (state === 'Less') stateLess();
    else if (state === 'More') stateMode();
    else if (state === 'Quote') stateQuote();
    else if (state === 'Rem') stateRem();
    else throw 1;

  }

}

module.exports = encode;
