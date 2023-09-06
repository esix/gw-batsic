const udword = require('./_udword');

test('ubyte.add', () => {
  expect(udword.add('00000000', '00000000')).toEqual(['00000000', '']);
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
