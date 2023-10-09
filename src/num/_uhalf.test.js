const uhalf = require('./_uhalf');

test('uhalf.check', () => {
  expect(uhalf.check('0')).toBe(true);
  expect(uhalf.check('1')).toBe(true);
  expect(uhalf.check('2')).toBe(true);
  expect(uhalf.check('9')).toBe(true);
  expect(uhalf.check('A')).toBe(true);
  expect(uhalf.check('B')).toBe(true);
  expect(uhalf.check('F')).toBe(true);
  expect(uhalf.check('a')).toBe(false);
  expect(uhalf.check('b')).toBe(false);
  expect(uhalf.check('f')).toBe(false);
  expect(uhalf.check('g')).toBe(false);
  expect(uhalf.check('G')).toBe(false);
  expect(uhalf.check('')).toBe(false);
  expect(uhalf.check('00')).toBe(false);
  expect(uhalf.check(' ')).toBe(false);
});

test('uhalf.inc', () => {
  expect(uhalf.inc('0')).toEqual(['1', '']);
  expect(uhalf.inc('1')).toEqual(['2', '']);
  expect(uhalf.inc('9')).toEqual(['A', '']);
  expect(uhalf.inc('A')).toEqual(['B', '']);
  expect(uhalf.inc('F')).toEqual(['0', '1']);
});

test('uhalf.dec', () => {
  expect(uhalf.dec('0')).toEqual(['F', '1']);
  expect(uhalf.dec('1')).toEqual(['0', '']);
  expect(uhalf.dec('9')).toEqual(['8', '']);
  expect(uhalf.dec('A')).toEqual(['9', '']);
  expect(uhalf.dec('F')).toEqual(['E', '']);
});

test('uhalf.add', () => {
  expect(uhalf.add('0', '0')).toEqual(['0', '']);
  expect(uhalf.add('1', '0')).toEqual(['1', '']);
  expect(uhalf.add('0', '1')).toEqual(['1', '']);
  expect(uhalf.add('8', '7')).toEqual(['F', '']);
  expect(uhalf.add('F', 'F')).toEqual(['E', '1']);
  expect(uhalf.add('F', '1')).toEqual(['0', '1']);
  expect(uhalf.add('F', '0')).toEqual(['F', '']);
});

test('uhalf.mul', () => {
  expect(uhalf.mul('0', '0')).toEqual('00');
  expect(uhalf.mul('1', '0')).toEqual('00');
  expect(uhalf.mul('1', 'F')).toEqual('0F');
  expect(uhalf.mul('2', 'F')).toEqual('1E');
  expect(uhalf.mul('F', 'F')).toEqual('E1');
});

test('uhalf.not', () => {
  expect(uhalf.not('0')).toEqual('F');
  expect(uhalf.not('1')).toEqual('E');
  expect(uhalf.not('2')).toEqual('D');
  expect(uhalf.not('3')).toEqual('C');
  expect(uhalf.not('5')).toEqual('A');
  expect(uhalf.not('9')).toEqual('6');
  expect(uhalf.not('A')).toEqual('5');
  expect(uhalf.not('F')).toEqual('0');
});