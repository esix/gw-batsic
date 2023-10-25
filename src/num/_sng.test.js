const sng = require("./sng");

test('sng.unpack', () => {
  expect(sng.unpack("00000000")).toStrictEqual({S: "0", E: "00", M: "00000000"}); // 0
  expect(sng.unpack("81000000")).toStrictEqual({S: "1", E: "01", M: "00800000"}); // 1
  expect(sng.unpack("82000000")).toStrictEqual({S: "1", E: "02", M: "00800000"}); // 2
  expect(sng.unpack("85000000")).toStrictEqual({S: "1", E: "05", M: "00800000"}); // 10
});

test('sng.pack', () => {
  expect(sng.pack("0", "00", "00000000")).toBe("00000000");
  expect(sng.pack("1", "01", "00800000")).toBe("81000000");
  expect(sng.pack("1", "02", "00800000")).toBe("82000000");
  expect(sng.pack("1", "05", "00800000")).toBe("85000000");
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


//  0   00000000
//  1   81000000
//  2   82000000
//  3   82400000
//  4   83000000
//  5   83200000
//  6   83400000
//  7   83600000
//  8   84000000
//  9   84100000
// 10   84200000
// 11   84300000
// 12   84400000
// 13   84500000
// 14   84600000
// 15   84700000
// 16   85000000

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

