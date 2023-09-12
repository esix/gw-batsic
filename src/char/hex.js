
function isValidHexSymbol(hex) {
  if (hex.length !== 1) return '';
  if ((hex >= '0' && hex <= '9') || (hex >= 'A' && hex <= 'F')) return 'T';
  return '';
}

function isValidChar(hexChar) {
  if (hexChar[2] === undefined &&
      isValidHexSymbol(hexChar.substr(0, 1)) &&
      isValidHexSymbol(hexChar.substr(1, 1)))
    return 'T';
  return '';
}

function isDigit(hexChar) {
  if (!isValidChar(hexChar)) throw 1;
  if (hexChar >= '30') {
    if (hexChar <= '39') {
      return 'T';
    }
  }
  return '';
}

function isMinus(hexChar) {
  if (!isValidChar(hexChar)) throw 1;
  if (hexChar === '2D') return 'T';
  return '';
}

function chr(hexChar) {
  if (!isValidChar(hexChar)) throw 1;
  return String.fromCharCode(parseInt(hexChar, 16));
}


module.exports = {isValidChar, isDigit, isMinus, chr};
