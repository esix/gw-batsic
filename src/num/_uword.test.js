const uword = require('./_uword');

test('uword.check', () => {
  expect(uword.check('0000')).toBe(true);
  expect(uword.check('0001')).toBe(true);
  expect(uword.check('0002')).toBe(true);
  expect(uword.check('1000')).toBe(true);
  expect(uword.check('9900')).toBe(true);
  expect(uword.check('A000')).toBe(true);
  expect(uword.check('FFFF')).toBe(true);
  expect(uword.check('AAA')).toBe(false);
  expect(uword.check('AA ')).toBe(false);
  expect(uword.check('0')).toBe(false);
  expect(uword.check('')).toBe(false);
});

test('uword.add', () => {
  expect(uword.add('0000', '0000')).toEqual(['0000', '']);
  expect(uword.add('0001', '0000')).toEqual(['0001', '']);
  expect(uword.add('0000', '0001')).toEqual(['0001', '']);
  expect(uword.add('0011', '0012')).toEqual(['0023', '']);
  expect(uword.add('0018', '0018')).toEqual(['0030', '']);
  expect(uword.add('0080', '0080')).toEqual(['0100', '']);
  expect(uword.add('0088', '0088')).toEqual(['0110', '']);
  expect(uword.add('0078', '0088')).toEqual(['0100', '']);
  expect(uword.add('00ff', '00ff')).toEqual(['01FE', '']);
  expect(uword.add('FFFF', 'ffff')).toEqual(['FFFE', '1']);
  expect(uword.add('7FFF', '8000')).toEqual(['FFFF', '']);
  expect(uword.add('7FFF', '8001')).toEqual(['0000', '1']);
});

test('uword.mul', () => {
  expect(uword.mul('0000', '0000')).toEqual('00000000');
  expect(uword.mul('0001', '0000')).toEqual('00000000');
  expect(uword.mul('FFFF', 'FFFF')).toEqual('FFFE0001');
  expect(uword.mul('1000', '0010')).toEqual('00010000');
});

