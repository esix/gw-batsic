const hex = require("./hex");

test('hex.isValidChar', () => {
  expect(hex.isValidChar('00')).toBe('T');
  expect(hex.isValidChar('AB')).toBe('T');
  expect(hex.isValidChar('A9')).toBe('T');
  expect(hex.isValidChar('8F')).toBe('T');
  expect(hex.isValidChar('FF')).toBe('T');
  expect(hex.isValidChar('')).toBe('');
  expect(hex.isValidChar('X0')).toBe('');
  expect(hex.isValidChar('ABC')).toBe('');
  expect(hex.isValidChar('9')).toBe('');
  expect(hex.isValidChar('ff')).toBe('');
});

test('hex.isDigit', () => {
  expect(hex.isDigit('00')).toBe('');
  expect(hex.isDigit('FF')).toBe('');
  expect(hex.isDigit('2F')).toBe('');
  expect(hex.isDigit('30')).toBe('T');
  expect(hex.isDigit('31')).toBe('T');
  expect(hex.isDigit('39')).toBe('T');
  expect(hex.isDigit('40')).toBe('');
});

