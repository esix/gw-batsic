//
//

// parse decimal value and store result.value (8 bits, signed or uinsigned)
//
//

const libdecimal = require('../libdecimal/libdecimal');
const {div16, parse} = libdecimal;


function _is_dec(val_sdec) {
  if (!val_sdec.match("^[\-+]?[0-9][0-9]*$")) return 1;
  return 0;
}

function _dec_to_xn(val_dec, var_result, n) {
  let var_dec = {_:val_dec};
  if (parse(var_dec) != 0) {
    return 2;
  }

  var_result._ = "";
  let quotient  = {_:""};
  let remainder  = {_:""};

  let d = var_dec._;

  for (let i = 0; i < n; i++) {
    div16(d, quotient, remainder);
    var_result._ = "0123456789ABCDEF"[+remainder._] + var_result._;

    d = quotient._;
  }

  let error = 1;
  if (d === "+0") error = 0;
  if (d === "-1") {
    if (remainder._ >= 8) error = 0;
  }
  return error;
}


function dec_to_x8(val_dec, var_result) {
  return _dec_to_xn(val_dec, var_result, 2);
}

function dec_to_x16(val_dec, var_result) {
  return _dec_to_xn(val_dec, var_result, 4);
}

function dec_to_x32(val_dec, var_result) {
  return _dec_to_xn(val_dec, var_result, 8);
}

function dec_to_x64(val_dec, var_result) {
  return _dec_to_xn(val_dec, var_result, 16);
}

function dec_to_x128(val_dec, var_result) {
  return _dec_to_xn(val_dec, var_result, 32);
}

//
// load unsigned decimal from hex
//
function u_to_dec(hex, result) {
  //
}

//
// load signed decimal from hex
//
function s_to_dec(hex, result) {
  
}


module.exports = {
  dec_to_x8, 
  dec_to_x16, 
  dec_to_x32, 
  dec_to_x64, 
  dec_to_x128, 
  u_to_dec, 
  s_to_dec,
};

