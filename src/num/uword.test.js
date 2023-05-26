const uword = require('./uword');

test('ubyte.add', () => {
  expect(uword.add('0000', '0000')).toEqual(['0000', '']);
  expect(uword.add('0001', '0000')).toEqual(['0001', '']);
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
