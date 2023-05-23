function toDec(hex) {
  let ret = '';
  if (hex === '0') ret = '0';
  if (hex === '1') ret = '1';
  if (hex === '2') ret = '2';
  if (hex === '3') ret = '3';
  if (hex === '4') ret = '4';
  if (hex === '5') ret = '5';
  if (hex === '6') ret = '6';
  if (hex === '7') ret = '7';
  if (hex === '8') ret = '8';
  if (hex === '9') ret = '9';
  if (hex === 'A') ret = '10';
  if (hex === 'a') ret = '10';
  if (hex === 'B') ret = '11';
  if (hex === 'b') ret = '11';
  if (hex === 'C') ret = '12';
  if (hex === 'c') ret = '12';
  if (hex === 'D') ret = '13';
  if (hex === 'd') ret = '13';
  if (hex === 'E') ret = '14';
  if (hex === 'e') ret = '14';
  if (hex === 'F') ret = '15';
  if (hex === 'f') ret = '15';

  if (ret === '') throw new Error();
  return ret;
}

function fromDec(dec) {
  let ret = '';
  if (dec === '0') ret = '0';
  if (dec === '1') ret = '1';
  if (dec === '2') ret = '2';
  if (dec === '3') ret = '3';
  if (dec === '4') ret = '4';
  if (dec === '5') ret = '5';
  if (dec === '6') ret = '6';
  if (dec === '7') ret = '7';
  if (dec === '8') ret = '8';
  if (dec === '9') ret = '9';
  if (dec === '10') ret = 'A';
  if (dec === '11') ret = 'B';
  if (dec === '12') ret = 'C';
  if (dec === '13') ret = 'D';
  if (dec === '14') ret = 'E';
  if (dec === '15') ret = 'F';

  if (ret === '') throw new Error();
  return ret;
}

module.exports = {toDec};

