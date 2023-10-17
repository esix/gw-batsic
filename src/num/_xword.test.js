const xword = require('./_xword');

test('uword.check', () => {
  expect(xword.check('0000')).toBe(true);
  expect(xword.check('0001')).toBe(true);
  expect(xword.check('0002')).toBe(true);
  expect(xword.check('1000')).toBe(true);
  expect(xword.check('9900')).toBe(true);
  expect(xword.check('A000')).toBe(true);
  expect(xword.check('FFFF')).toBe(true);
  expect(xword.check('AAA')).toBe(false);
  expect(xword.check('AA ')).toBe(false);
  expect(xword.check('0')).toBe(false);
  expect(xword.check('')).toBe(false);
});

test('uword.add', () => {
  expect(xword.add('0000', '0000')).toEqual(['0000', '']);
  expect(xword.add('0001', '0000')).toEqual(['0001', '']);
  expect(xword.add('0000', '0001')).toEqual(['0001', '']);
  expect(xword.add('0011', '0012')).toEqual(['0023', '']);
  expect(xword.add('0018', '0018')).toEqual(['0030', '']);
  expect(xword.add('0080', '0080')).toEqual(['0100', '']);
  expect(xword.add('0088', '0088')).toEqual(['0110', '']);
  expect(xword.add('0078', '0088')).toEqual(['0100', '']);
  expect(xword.add('00FF', '00FF')).toEqual(['01FE', '']);
  expect(xword.add('FFFF', 'FFFF')).toEqual(['FFFE', '1']);
  expect(xword.add('7FFF', '8000')).toEqual(['FFFF', '']);
  expect(xword.add('7FFF', '8001')).toEqual(['0000', '1']);
});

test('uword.mul', () => {
  expect(xword.mul('0000', '0000')).toEqual('00000000');
  expect(xword.mul('0001', '0000')).toEqual('00000000');
  expect(xword.mul('FFFF', 'FFFF')).toEqual('FFFE0001');
  expect(xword.mul('1000', '0010')).toEqual('00010000');
});

