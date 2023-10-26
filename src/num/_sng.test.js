const sng = require("./sng");

const TESTS = {
  '-1': {mbf: "81800000", unpacked: {S: "-1", E: "01", M: "00800000"}, dec: "-1!", sb: "FF" },
  '0' : {mbf: "00000000", unpacked: {S:  "0", E: "00", M: "00000000"}, dec: "0!" , sb: "00" },
  '1' : {mbf: "81000000", unpacked: {S:  "1", E: "01", M: "00800000"}, dec: "1!" , sb: "01" },
  '2' : {mbf: "82000000", unpacked: {S:  "1", E: "02", M: "00800000"}, dec: "2!" , sb: "02" },
  '3' : {mbf: "82400000", unpacked: {S:  "1", E: "02", M: "00C00000"}, dec: "3!" , sb: "03" },
  '4' : {mbf: "83000000", unpacked: {S:  "1", E: "03", M: "00800000"}, dec: "4!" , sb: "04" },
  '5' : {mbf: "83200000", unpacked: {S:  "1", E: "03", M: "00A00000"}, dec: "5!" , sb: "05" },
  '6' : {mbf: "83400000", unpacked: {S:  "1", E: "03", M: "00C00000"}, dec: "6!" , sb: "06" },
  '7' : {mbf: "83600000", unpacked: {S:  "1", E: "03", M: "00E00000"}, dec: "7!" , sb: "07" },
  '8' : {mbf: "84000000", unpacked: {S:  "1", E: "04", M: "00800000"}, dec: "8!" , sb: "08" },
  '9' : {mbf: "84100000", unpacked: {S:  "1", E: "04", M: "00900000"}, dec: "9!" , sb: "09" },
  '10': {mbf: "84200000", unpacked: {S:  "1", E: "04", M: "00A00000"}, dec: "10!", sb: "0A" },
  '11': {mbf: "84300000", unpacked: {S:  "1", E: "04", M: "00B00000"}, dec: "11!", sb: "0B" },
  '12': {mbf: "84400000", unpacked: {S:  "1", E: "04", M: "00C00000"}, dec: "12!", sb: "0C" },
  '13': {mbf: "84500000", unpacked: {S:  "1", E: "04", M: "00D00000"}, dec: "13!", sb: "0D" },
  '14': {mbf: "84600000", unpacked: {S:  "1", E: "04", M: "00E00000"}, dec: "14!", sb: "0E" },
  '15': {mbf: "84700000", unpacked: {S:  "1", E: "04", M: "00F00000"}, dec: "15!", sb: "0F" },
  '16': {mbf: "85000000", unpacked: {S:  "1", E: "05", M: "00800000"}, dec: "16!", sb: "10" },
}


test('sng.unpack', () => {
  expect(sng.unpack("00000000")).toStrictEqual({S: "0", E: "00", M: "00000000"});
  for (let tst of Object.values(TESTS)) {
    expect(sng.unpack(tst.mbf)).toStrictEqual(tst.unpacked);
  }
});

test('sng.pack', () => {
  expect(sng.pack("0", "00", "00000000")).toBe("00000000");
  for (let tst of Object.values(TESTS)) {
    expect(sng.pack(tst.unpacked.S, tst.unpacked.E, tst.unpacked.M)).toBe(tst.mbf);
  }
});

test('sng.serialize', () => {
  expect(sng.serialize('00000000')).toBe('0');
  // expect(sng.serialize('80000000')).toBe('0.5');
  // expect(sng.serialize('81400000')).toBe('1.5');
  // expect(sng.serialize('9117E880')).toBe('77777');
  // expect(sng.serialize('7E4CCCCD')).toBe('0.2');
});

test('sng.fromSB', () => {
  expect(sng.fromSB('00')).toBe('00000000');
  // expect(sng.fromSB('01')).toBe('81000000');
  // expect(sng.fromSB('02')).toBe('82000000');
  // expect(sng.fromSB('03')).toBe('82400000');
  // expect(sng.fromSB('04')).toBe('83000000');
  // expect(sng.fromSB('05')).toBe('83200000');
  // expect(sng.fromSB('06')).toBe('83400000');
  // expect(sng.fromSB('07')).toBe('83600000');
  // expect(sng.fromSB('08')).toBe('84000000');
  // expect(sng.fromSB('09')).toBe('84100000');
  // expect(sng.fromSB('0A')).toBe('84200000');
  // expect(sng.fromSB('0B')).toBe('84300000');
  // expect(sng.fromSB('0C')).toBe('84400000');
  // expect(sng.fromSB('0D')).toBe('84500000');
  // expect(sng.fromSB('0E')).toBe('84600000');
  // expect(sng.fromSB('0F')).toBe('84700000');
  // expect(sng.fromSB('10')).toBe('85000000');
});


// 0.5                  .5                        80000000
// 0.25                 .25                       7F000000
// 0.125                .125                      7E000000
// 0.0625               .0625                     7D000000
// 0.03125              .03125                    7C000000
// 0.015625             .015625                   7B000000
// 0.0078125            .0078125                  7A000000
// 0.00390625           3.90625E-03               79000000
// 0.001953125          1.953125E-03              78000000
// 0.0009765625         9.765625E-04              77000000
// 0.00048828125        4.882813E-04              76000000
// 0.000244140625       2.441406E-04              75000000
// 0.0001220703125      1.220703E-04              74000000
// 0.00006103515625     6.103516E-05              73000000
// 0.000030517578125    3.051758E-05              72000000
// 0.0000152587890625   1.525879E-05              71000000

