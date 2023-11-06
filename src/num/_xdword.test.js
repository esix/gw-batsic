const xdword = require('./_xdword');

test('xdword.add', () => {
  expect(xdword.add('00000000', '00000000')).toEqual(['00000000', '']);
  // expect(udword.add('0001', '0000')).toEqual(['0001', '']);
  // expect(udword.add('0000', '0001')).toEqual(['0001', '']);
  // expect(udword.add('0011', '0012')).toEqual(['0023', '']);
  // expect(udword.add('0018', '0018')).toEqual(['0030', '']);
  // expect(udword.add('0080', '0080')).toEqual(['0100', '']);
  // expect(udword.add('0088', '0088')).toEqual(['0110', '']);
  // expect(udword.add('0078', '0088')).toEqual(['0100', '']);
  // expect(udword.add('00ff', '00ff')).toEqual(['01FE', '']);
  // expect(udword.add('FFFF', 'ffff')).toEqual(['FFFE', '1']);
  // expect(udword.add('7FFF', '8000')).toEqual(['FFFF', '']);
  // expect(udword.add('7FFF', '8001')).toEqual(['0000', '1']);
});

test('xdword.bsr', () => {
  expect(xdword.bsr('00000000')).toBe('0');
  expect(xdword.bsr('00000001')).toBe('1');
  expect(xdword.bsr('00000011')).toBe('5');
  expect(xdword.bsr('000000F1')).toBe('8');
  expect(xdword.bsr('0000FFFF')).toBe('16');
  expect(xdword.bsr('00030000')).toBe('18');
  expect(xdword.bsr('FFFFFFFF')).toBe('32');
});
