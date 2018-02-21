// libdecimal: Decimal integer arithmetics
//
// https://github.com/MikeMcl/big.js/blob/master/big.js
//
// 
//  gwbasic in INPUT command ignores spaces
//  valid decimals in gwbasic:
//    "1"                 => 1
//    "0"                 => 0
//    "    -  2   4"      => -24
//    "   + 1 0 0 "       => 100
//    "-0"                => 0
// 
//
//  invalid: multiple -- or -+
//


function _is_digit(c) {
  return '0' <= c && c <= '9';
}


//
//  parse rawDecimal containing spaces and optional sign
//  to non spaces decimal and sign
//
function parse(var_dec) {
  let state = 0;
  let sign = "+";
  let result = "";
  let len = String(var_dec._).length;
  let c = "";
  let i;

  for (i = 0; i < len; i++) {
    c = String(var_dec._)[i];
    switch(state) {
      case 0:
        if (c === "+") state = 1;
        else if (c === "-") { sign = "-"; state = 1; }
        else if (c === "0") { state = 1; }                                       // trailing zeros
        else if (_is_digit(c)) { result = result + c; state = 2; }
        else if (c === " ") {}
        else state = -1;
        break;
      
      case 1:
        if (c === "0") {}
        else if (c === " ") {}
        else if (_is_digit(c)) { result = result + c; state = 2; }
        else state = -1;
        break;

      case 2:
        if (_is_digit(c)) { result = result + c; }
        else if (c === " ") {}
        else state = -1;
        break;
    }
  }

  if (state === 1) { result = "0"; sign = "+"; state = 2; }
  var_dec._ = sign + result;

  let error = 1;
  if (state === 2) {
    error = 0;
  }

  return error;
}


function _inc(var_udec) {
  let i = var_udec._.length - 1;
  let result = "";
  let o = 1;

  while (i >= 0) {
    let digit = var_udec._[i];
    digit = +digit + o;
    if (digit === 10) {
      o = 1;
      result = "0" + result;
    } else {
      o = 0;
      result = String(digit) + result;
    }
    i--;
  }
  if (o === 1) {
    result = "1" + result;
  }
  var_udec._ = result;
}


// work only in var_udec != 0 (>0)
function _dec(var_udec) {
  var i = var_udec._.length - 1;
  var result = "";
  var o = 1;

  while (i >= 0) {
    var d = var_udec._[i];
    d = +d - o;
    if (d == -1) {
      o = 1;
      result = "9" + result;
    } else {
      o = 0;
      result = String(d) + result;
    }
    i--;
  }
  if (result.length > 1 && result[0] == "0") result = result.substring(1);
  var_udec._ = result;
}


function dec(var_sdec) {
  let error = parse(var_sdec);
  if (error !== 0) {
    return 1;
  }

  let var_udec = {_: var_sdec._.substring(1)};

  if (var_sdec._[0] === "-") {
    _inc(var_udec);
    var_sdec._ = "-" + var_udec._;
  } else if (var_sdec._ === "+0") {
    var_sdec._ = "-1";
  } else {
    _dec(var_udec);
    var_sdec._ = "+" + var_udec._;
  }

  return 0;
}




// one iteration of division by 16
// -  udec - [in, out] unsigned decimal divider
// -  result - accumulator of quotent
function _udiv16(val_udec, var_quotent, var_remainder) {

  let acc = "";
  var_quotent._ = "";

  for (let i = 0; i < val_udec.length; i++) {
    let digit = val_udec[i];
    acc = acc + digit;
    var_quotent._ += Math.floor(acc / 16);
    acc = acc % 16;
  }
  var_remainder._ = String(acc);
  return 0;
}



// return a / 16 and a % 16
function div16(val_sdec, var_quotent, var_remainder) {
  let var_sdec = {_: val_sdec};

  let error = parse(var_sdec);
  if (error !== 0) {
    return 1;
  }

  let r = {_:""};
  let q = {_:""};
  _udiv16(var_sdec._.substring(1), q, r);

  if (var_sdec._[0] === "-") {
    r._ = String(16 - r._);
    q._ = -q._ ;                           // might be overflow
    if (r._ !== "16") dec(q);
    if (r._ === "16")  r._ = 0;
  }

  parse(q);
  parse(r);

  var_quotent._ = String(q._);
  var_remainder._ = String(r._);

  // console.log("Div16", var_sdec, " ==> ", "q=", var_quotent._, "r=",var_remainder._);
  return 0;
}

module.exports = {
  parse, div16, dec,
};


