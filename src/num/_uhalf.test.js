const uhalf = require('./_uhalf');

test('uhalf.check', () => {
  expect(uhalf.check('0')).toBe(true);
  expect(uhalf.check('1')).toBe(true);
  expect(uhalf.check('2')).toBe(true);
  expect(uhalf.check('9')).toBe(true);
  expect(uhalf.check('a')).toBe(true);
  expect(uhalf.check('A')).toBe(true);
  expect(uhalf.check('b')).toBe(true);
  expect(uhalf.check('B')).toBe(true);
  expect(uhalf.check('f')).toBe(true);
  expect(uhalf.check('F')).toBe(true);
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
  expect(uhalf.inc('a')).toEqual(['B', '']);
  expect(uhalf.inc('F')).toEqual(['0', '1']);
});

test('uhalf.add', () => {
  expect(uhalf.add('0', '0')).toEqual(['0', '']);
  expect(uhalf.add('1', '0')).toEqual(['1', '']);
  expect(uhalf.add('0', '1')).toEqual(['1', '']);
  expect(uhalf.add('8', '7')).toEqual(['F', '']);
  expect(uhalf.add('F', 'F')).toEqual(['E', '1']);
  expect(uhalf.add('F', '1')).toEqual(['0', '1']);
  expect(uhalf.add('F', '0')).toEqual(['F', '']);
})

test('uhalf.mul', () => {
  expect(uhalf.mul('0', '0')).toEqual('00');
  expect(uhalf.mul('1', '0')).toEqual('00');
  expect(uhalf.mul('1', 'F')).toEqual('0F');
  expect(uhalf.mul('2', 'F')).toEqual('1E');
  expect(uhalf.mul('F', 'F')).toEqual('E1');
})