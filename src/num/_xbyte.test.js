const xbyte = require('./_xbyte');

test('xbyte.check', () => {
  expect(xbyte.check('00')).toBe(true);
  expect(xbyte.check('01')).toBe(true);
  expect(xbyte.check('02')).toBe(true);
  expect(xbyte.check('10')).toBe(true);
  expect(xbyte.check('99')).toBe(true);
  expect(xbyte.check('A0')).toBe(true);
  expect(xbyte.check('AAA')).toBe(false);
  expect(xbyte.check('AA ')).toBe(false);
  expect(xbyte.check('0')).toBe(false);
  expect(xbyte.check('')).toBe(false);
});

test('xbyte.parse', () => {
  expect(xbyte.parse('0')).toBe('00');
  expect(xbyte.parse('1')).toBe('01');
  expect(xbyte.parse('255')).toBe('FF');
});

test('xbyte.lt', () => {
  expect(xbyte.lt('00', '00')).toEqual('');
  expect(xbyte.lt('00', '01')).toEqual('1');
});

test('xbyte.add', () => {
  expect(xbyte.add('00', '00')).toEqual(['00', '']);
  expect(xbyte.add('01', '00')).toEqual(['01', '']);
  expect(xbyte.add('11', '12')).toEqual(['23', '']);
  expect(xbyte.add('18', '18')).toEqual(['30', '']);
  expect(xbyte.add('80', '80')).toEqual(['00', '1']);
  expect(xbyte.add('88', '88')).toEqual(['10', '1']);
  expect(xbyte.add('78', '88')).toEqual(['00', '1']);
  expect(xbyte.add('FF', 'FF')).toEqual(['FE', '1']);
});

test('xbyte.sub', () => {
  expect(xbyte.sub('01', '00')).toEqual(['01', '']);
  expect(xbyte.sub('88', '08')).toEqual(['80', '']);
});

test('xbyte.toBin', () => {
  expect(xbyte.toBin('00')).toBe('00000000');
  expect(xbyte.toBin('41')).toBe('01000001');
  expect(xbyte.toBin('FF')).toBe('11111111');
})

test('xbyte.fromBin', () => {
  expect(xbyte.fromBin('00000000')).toBe('00');
  expect(xbyte.fromBin('01000001')).toBe('41');
  expect(xbyte.fromBin('11111111')).toBe('FF');
});

test('xbyte.mul', () => {
  expect(xbyte.mul('AB', 'CD')).toEqual('88EF');
  expect(xbyte.mul('FF', 'FF')).toEqual('FE01');
  expect(xbyte.mul('10', '00')).toEqual('0000');
  expect(xbyte.mul('00', '00')).toEqual('0000');
  expect(xbyte.mul('08', '81')).toEqual('0408');
});

test('xbyte.toBin', () => {
  expect(xbyte.toBin('01')).toEqual('00000001');
  expect(xbyte.toBin('F4')).toEqual('11110100');
});

test('xbyte.and', () => {
  expect(xbyte.and('01', '03')).toEqual('01');
});

test('xbyte.or', () => {
  expect(xbyte.or('01', '03')).toEqual('03');
});

test('xbyte.not', () => {
  expect(xbyte.not('00')).toEqual('FF');
  expect(xbyte.not('01')).toEqual('FE');
});

test('xbyte.neg', () => {
  expect(xbyte.neg('00')).toEqual('00');
  expect(xbyte.neg('01')).toEqual('FF');
  expect(xbyte.neg('FF')).toEqual('01');
  expect(xbyte.neg('FE')).toEqual('02');
});

test('xbyte.shl', () => {
  expect(xbyte.shl('01', '0')).toEqual('01');
  expect(xbyte.shl('01', '1')).toEqual('02');
  expect(xbyte.shl('08', '1')).toEqual('10');
  expect(xbyte.shl('02', '3')).toEqual('10');
  expect(xbyte.shl('02', '7')).toEqual('00');
});

test('xbyte.shr', () => {
  expect(xbyte.shr('01', '0')).toEqual('01');
  expect(xbyte.shr('01', '1')).toEqual('00');
  expect(xbyte.shr('08', '1')).toEqual('04');
  expect(xbyte.shr('02', '3')).toEqual('00');
  expect(xbyte.shr('02', '7')).toEqual('00');
});

test('xbyte.slt', () => {
  expect(xbyte.slt('00', '01')).toEqual('1');
  expect(xbyte.slt('01', '00')).toEqual('0');
  expect(xbyte.slt('01', '01')).toEqual('0');
  expect(xbyte.slt('80', '7F')).toEqual('1');
  expect(xbyte.slt('80', '00')).toEqual('1');
  expect(xbyte.slt('7F', '00')).toEqual('0');
  expect(xbyte.slt('AA', 'AB')).toEqual('1');
  expect(xbyte.slt('80', '81')).toEqual('1');
});

test('xbyte.bsr', () => {
  expect(xbyte.bsr('00')).toEqual('0');
  expect(xbyte.bsr('01')).toEqual('1');
  expect(xbyte.bsr('07')).toEqual('3');
  expect(xbyte.bsr('80')).toEqual('8');
  expect(xbyte.bsr('7F')).toEqual('7');
});
