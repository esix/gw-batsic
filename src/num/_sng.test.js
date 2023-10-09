const sng = require('./sng');

test('sng.serialize', () => {
  expect(sng.serialize('80000000')).toBe('0.5');
  expect(sng.serialize('00000000')).toBe('0');
  expect(sng.serialize('81400000')).toBe('1.5');
  expect(sng.serialize('9117E880')).toBe('77777');
  // expect(sng.serialize('7E4CCCCD')).toBe('0.2')
});
