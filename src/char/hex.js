
function isValidHexSymbol(x) {
  if (x.length !== 1) return '';
  if ((x >= '0' && x <= '9') || (x >= 'A' && x <= 'F')) return 'T';
  return '';
}

function isValidChar(xc) {
  if (xc[2] === undefined &&
      isValidHexSymbol(xc.substr(0, 1)) &&
      isValidHexSymbol(xc.substr(1, 1)))
    return 'T';
  return '';
}

function isDigit(xc) {
  if (!isValidChar(xc)) throw 1;
  if (xc >= '30') {
    if (xc <= '39') {
      return 'T';
    }
  }
  return '';
}

function isZero(xc) {
  if (!isValidChar(xc)) throw 1;
  if (xc === '30') return 'T';
  return '';
}

function isMinus(xc) {
  if (!isValidChar(xc)) throw 1;
  if (xc === '2D') return 'T';
  return '';
}

function chr(xc) {
  if (!isValidChar(xc)) throw 1;
  return String.fromCharCode(parseInt(xc, 16));
}


module.exports = {isValidChar, isDigit, isZero, isMinus, chr};
