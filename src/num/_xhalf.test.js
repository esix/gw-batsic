const xhalf = require('./_xhalf');

test('uhalf.check', () => {
  expect(xhalf.check('0')).toBe(true);
  expect(xhalf.check('1')).toBe(true);
  expect(xhalf.check('2')).toBe(true);
  expect(xhalf.check('9')).toBe(true);
  expect(xhalf.check('A')).toBe(true);
  expect(xhalf.check('B')).toBe(true);
  expect(xhalf.check('F')).toBe(true);
  expect(xhalf.check('a')).toBe(false);
  expect(xhalf.check('b')).toBe(false);
  expect(xhalf.check('f')).toBe(false);
  expect(xhalf.check('g')).toBe(false);
  expect(xhalf.check('G')).toBe(false);
  expect(xhalf.check('')).toBe(false);
  expect(xhalf.check('00')).toBe(false);
  expect(xhalf.check(' ')).toBe(false);
});

test('uhalf.inc', () => {
  expect(xhalf.inc('0')).toEqual(['1', '']);
  expect(xhalf.inc('1')).toEqual(['2', '']);
  expect(xhalf.inc('9')).toEqual(['A', '']);
  expect(xhalf.inc('A')).toEqual(['B', '']);
  expect(xhalf.inc('F')).toEqual(['0', '1']);
});

test('uhalf.dec', () => {
  expect(xhalf.dec('0')).toEqual(['F', '1']);
  expect(xhalf.dec('1')).toEqual(['0', '']);
  expect(xhalf.dec('9')).toEqual(['8', '']);
  expect(xhalf.dec('A')).toEqual(['9', '']);
  expect(xhalf.dec('F')).toEqual(['E', '']);
});

test('uhalf.add', () => {
  expect(xhalf.add('0', '0')).toEqual(['0', '']);
  expect(xhalf.add('1', '0')).toEqual(['1', '']);
  expect(xhalf.add('0', '1')).toEqual(['1', '']);
  expect(xhalf.add('8', '7')).toEqual(['F', '']);
  expect(xhalf.add('F', 'F')).toEqual(['E', '1']);
  expect(xhalf.add('F', '1')).toEqual(['0', '1']);
  expect(xhalf.add('F', '0')).toEqual(['F', '']);
});

test('uhalf.mul', () => {
  expect(xhalf.mul('0', '0')).toEqual('00');
  expect(xhalf.mul('1', '0')).toEqual('00');
  expect(xhalf.mul('1', 'F')).toEqual('0F');
  expect(xhalf.mul('2', 'F')).toEqual('1E');
  expect(xhalf.mul('F', 'F')).toEqual('E1');
});

test('uhalf.not', () => {
  expect(xhalf.not('0')).toEqual('F');
  expect(xhalf.not('1')).toEqual('E');
  expect(xhalf.not('2')).toEqual('D');
  expect(xhalf.not('3')).toEqual('C');
  expect(xhalf.not('5')).toEqual('A');
  expect(xhalf.not('9')).toEqual('6');
  expect(xhalf.not('A')).toEqual('5');
  expect(xhalf.not('F')).toEqual('0');
});

test('uhalf.and', () => {
  expect(xhalf.and('0', '1')).toEqual('0');
  expect(xhalf.and('F', '1')).toEqual('1');
  expect(xhalf.and('5', 'B')).toEqual('1');
  expect(xhalf.and('F', 'F')).toEqual('F');
});

test('uhalf.or', () => {
  expect(xhalf.or('0', '1')).toEqual('1');
  expect(xhalf.or('F', '1')).toEqual('F');
  expect(xhalf.or('5', 'B')).toEqual('F');
  expect(xhalf.or('F', 'F')).toEqual('F');
});
