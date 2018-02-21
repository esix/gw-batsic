// http://krashan.ppa.pl/articles/stringtofloat/
// state machine


// https://github.com/kazuho/ieee754.js/blob/master/ieee754.js

function buildFloatDecoder(numBytes, exponentBits, exponentBias) {
    var eMax = (1 << exponentBits) - 1;
    var significandBias = Math.pow(2, -(8 * numBytes - 1 - exponentBits));
  
    return function (bytes, offset) {
  
      // convert to binary string "00101010111011..."
      var leftBits = "";
      for (var i = 0; i != numBytes; ++i) {
        var t = bytes[i + offset].toString(2);
        t = "00000000".substring(t.length) + t;
        leftBits += t;
      }
  
      // shift sign bit
      var sign = leftBits.charAt(0) == "1" ? -1 : 1;
      leftBits = leftBits.substring(1);
  
      // obtain exponent
      var exponent = parseInt(leftBits.substring(0, exponentBits), 2);
      leftBits = leftBits.substring(exponentBits);
  
      // take action dependent on exponent
      if (exponent == eMax) {
        return sign * Infinity;
      } else if (exponent == 0) {
        exponent += 1;
        var significand = parseInt(leftBits, 2);
      } else {
        significand = parseInt("1" + leftBits, 2);
      }
  
      return sign * significand * significandBias * Math.pow(2, exponent - exponentBias);
    };
}
  
var decodeFloat32 = buildFloatDecoder(4, 8, 127);
var decodeFloat64 = buildFloatDecoder(8, 11, 1023);





// https://github.com/rtoal/ieee754/blob/master/ieee754.js


//
//
//

//
// return binary represenation of number
//  the result.value will be of the form "41500000"
// 
function f32(strDec, result) {
  //
}


function f64(strDec, result) {
  //
}


function _dec_from_f32(f, result) {
}


function _dec_from_f64(f, result) {

}


// return decimal string value from provided 32 or 64 bits floaf
function dec(f, result) {
  if (f.length == 8) return _dec_from_f32(f, result);
  if (f.length == 16) return _dec_from_f64(f, result);
  return 1;
}



module.exports = {
  f32,
  f64,
  dec,
};


