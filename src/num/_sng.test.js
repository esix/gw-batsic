const sng = require("./sng");

test('sng.unpack', () => {
  expect(sng.unpack("00000000")).toStrictEqual({S: "0", E: "00", M: "00000000"});
  expect(sng.unpack("81000000")).toStrictEqual({S: "1", E: "01", M: "00800000"});
  expect(sng.unpack("82000000")).toStrictEqual({S: "1", E: "02", M: "00800000"});
});

test('sng.pack', () => {
  expect(sng.pack("0", "00", "00000000")).toBe("00000000");
  expect(sng.pack("1", "01", "00800000")).toBe("81000000");
  expect(sng.pack("1", "02", "00800000")).toBe("82000000");
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
  expect(sng.fromSB('01')).toBe('81000000');
  expect(sng.fromSB('02')).toBe('82000000');
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
