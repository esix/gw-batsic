const integer = require('./integer');

test('integer.parse', () => {
  expect(integer.parse('0')).toBe('0000');
  expect(integer.parse('32767')).toBe('7FFF');
  expect(integer.parse('-32768')).toBe('8000');
});
