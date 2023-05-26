const ubyte = require('./ubyte');

test('ubyte.check', () => {
  expect(ubyte.check('00')).toBe(true);
  expect(ubyte.check('01')).toBe(true);
  expect(ubyte.check('02')).toBe(true);
  expect(ubyte.check('10')).toBe(true);
  expect(ubyte.check('99')).toBe(true);
  expect(ubyte.check('A0')).toBe(true);
  expect(ubyte.check('AAA')).toBe(false);
  expect(ubyte.check('AA ')).toBe(false);
  expect(ubyte.check('0')).toBe(false);
  expect(ubyte.check('')).toBe(false);
});

test('ubyte.add', () => {
  expect(ubyte.add('00', '00')).toEqual(['00', '']);
  expect(ubyte.add('01', '00')).toEqual(['01', '']);
  expect(ubyte.add('11', '12')).toEqual(['23', '']);
  expect(ubyte.add('18', '18')).toEqual(['30', '']);
  expect(ubyte.add('80', '80')).toEqual(['00', '1']);
  expect(ubyte.add('88', '88')).toEqual(['10', '1']);
  expect(ubyte.add('78', '88')).toEqual(['00', '1']);
  expect(ubyte.add('ff', 'ff')).toEqual(['FE', '1']);
});
