const str = require('./str');

test('str.toX', () => {
  expect(str.toX('abcd')).toBe('61626364');
  expect(str.toX('+*,')).toBe('2B2A2C');
  expect(str.toX('Hello World')).toBe('48656C6C6F20576F726C64');
});
