const num = require("./num");

test('parse.parse', () => {
  expect(num.parse('0')).toBe('INT_0000');
  expect(num.parse('32767')).toBe('INT_7FFF');
  expect(num.parse('-32768')).toBe('INT_8000');
});
