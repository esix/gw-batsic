const readline = require('readline');
const {str2hex, StrLen} = require('../libs/libchar/libchar');


async function repl() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
  let error = 0;

  while (true) {
    const line = await new Promise(resolve => rl.question('Ok> ', resolve));
    if (line == '') break;
    let arg = {line, tokens: []};
    let error = tokenize(arg);
    console.log(arg.tokens);
  }

  rl.close();
}


function tokenize(line) {
  let hexLine = str2hex(line);
  let len = StrLen(hexLine);
  len = len / 2;
  let error = 0;

  let sm = {
    state: 1,
    acc: '',
    tokens: [],
  };


  for (let i = 0; i < len; i++) {
    let hexCode = hexLine.substr(i, 2);
    error = _SMEvent(hexCode, sm);
    if (error == 100) { i = i - 1; error = 0; }
    if (error != 0) break;
  }

  if (error == 0) {
    error = _SMEvent('0A', sm);
    if (error == 100) error = _SMEvent('0A', sm);
  }
  // return error;
  return sm.tokens;
}


function _SMEvent(hexCode, sm) {
  let charCode = parseInt(hexCode, 16);
  let char = String.fromCharCode(charCode);
  let nextState = '';
  let error = 0;

  let {state, acc, tokens} = sm;

  if (state == 0) {
    // Ok state: nothing should be after
    // if there is then error
  }
  if (state == 1) {
    // :
    if (hexCode == '3A') { PushToken('COLN', tokens); nextState=1; }
    // ;
    if (hexCode == '3B') { PushToken('SCLN', tokens); nextState=1; }
    // ,
    if (hexCode == '2C') { PushToken('COMM', tokens); nextState=1; }
    // +
    if (hexCode == '2B') { PushToken('PLUS', tokens); nextState=1; }
    // -
    if (hexCode == '2D') { PushToken('MINS', tokens); nextState=1; }
    // *
    if (hexCode == '2A') { PushToken('MULT', tokens); nextState=1; }
    // /
    if (hexCode == '2F') { PushToken('DIV_', tokens); nextState=1; }
    // \
    if (hexCode == '5C') { PushToken('IDIV', tokens); nextState=1; }
    // =
    if (hexCode == '3D') { PushToken('EQL_', tokens); nextState=1; }
    // (
    if (hexCode == '28') { PushToken('OPAR', tokens); nextState=1; }
    // )
    if (hexCode == '29') { PushToken('CPAR', tokens); nextState=1; }
    // space
    if (hexCode == '20') { nextState=1; }
    // tab
    if (hexCode == '07') { nextState=1; }
    // <
    if (hexCode == '3C') { nextState=2; }
    // >
    if (hexCode == '3E') { nextState=3; }
    // 0..9
    if (_isDigit(hexCode)) { acc=char; nextState=4; }
    // a..zA-Z
    if (_isAlpha(hexCode)) { acc=char; nextState=10; }
    // "
    if (hexCode == '22')  { acc=''; nextState=9; }
    // EOL
    if (hexCode == '0A')  { nextState=0;  }
  }

  if (state==2) {
    // =
    if (hexCode=='3D') { PushToken('LEQU', tokens); nextState=1; }
    // >
    if (hexCode=='3E') { PushToken('NEQU', tokens); nextState=1; }
    //  else
    if (nextState=='') { PushToken('LESS', tokens); nextState=1; error=100; }
  }

  if (state==3) {
    // TODO
  }
  if (state==4) {
    // 0..9
    if (_isDigit(hexCode)) {
      acc  = acc + char;
      nextState=4;
    }
    // TODO e, E
    // else
    if (nextState=='') {
      PushTokenInt(acc, tokens);
      acc='';
      nextState=1;
      error=100;
    }
  }

  if (state==9) {
    // "
    if (hexCode=='22') { PushToken('STR_' + acc, tokens); acc=''; nextState=1; }
    //  EOL
    if (hexCode=='0A') { PushToken('STR_' + acc, tokens); acc=''; nextState=0; }
    // else
    if (nextState=='') {
      acc= acc + hexCode;
      nextState=9;
    }
  }

  if (state==10) {
    if (_isAlpha(hexCode)) {
      acc= acc + char;
      nextState=10;
    }
    // $
    if (hexCode=='24') { PushTokenId(acc + '$', tokens); acc=''; nextState=1; }
    // %
    if (hexCode=='25') { PushTokenId(acc + '%', tokens); acc=''; nextState=1; }
    // !
    if (hexCode=='21') { PushTokenId(acc + '!', tokens); acc=''; nextState=1; }
    // #
    if (hexCode=='23') { PushTokenId(acc + '#', tokens); acc=''; nextState=1; }
    // else
    if (nextState=='') {
        PushTokenId(acc, tokens);
        acc='';
        nextState=1;
        // rem  100 - "Lexer: Please, repeat char"
        error=100;
    }
  }

  if (state==-1) {
    // This is fail state and no event can make us leave it
    nextState=-1;
  }

  // nextState is empty: unknown char, FAIL
  if (nextState=='') {
    //The state was not set means it failed
    // echo [lexer]: Failed at state !state!, char=!char! hex=!hexCode!
    // 2 - "Syntax error"
    error=2;
    nextState=-1;
  }

  state=nextState;

  sm.state = state;
  sm.acc = acc;
  sm.tokens = tokens;

  return error;
}



function _isDigit(hexCode) {
  let charCode = parseInt(hexCode, 16);
  return 48 <= charCode && charCode <= 57;
}


function _isAlpha(hexCode) {
  let charCode = parseInt(hexCode, 16);
  return 65 <= charCode && charCode <= 90 ||
      97 <= charCode && charCode <= 122;
}


function PushTokenId(id, tokens) {
  return PushToken('VAR_' + id, tokens);
}

function  PushToken(token, tokens) {
  tokens.push(token);
}


function PushTokenInt(hexNum, tokens) {
  tokens.push("I16_" + hexNum, tokens);
}





module.exports = {
  repl,
  tokenize,
};
