const sng = require("./sng");

const TESTS = {
  "-1!"         : {mbf: "81800000", unpacked: {S: "-1", E: "01", M: "00800000"}, sb: "FF" },
  "0!"          : {mbf: "00000000", unpacked: {S:  "0", E: "00", M: "00000000"}, sb: "00" },
  "1.525879E-05": {mbf: "71000000", unpacked: {S:  "1", E: "F1", M: "00800000"},          },          // 1/65536 = 0.0000152587890625
  "3.051758E-05": {mbf: "72000000", unpacked: {S:  "1", E: "F2", M: "00800000"},          },          // 1/32768 = 0.000030517578125
  "6.103516E-05": {mbf: "73000000", unpacked: {S:  "1", E: "F3", M: "00800000"},          },          // 1/16384 = 0.00006103515625
  "1.220703E-04": {mbf: "74000000", unpacked: {S:  "1", E: "F4", M: "00800000"},          },          // 1/8192  = 0.0001220703125
  "2.441406E-04": {mbf: "75000000", unpacked: {S:  "1", E: "F5", M: "00800000"},          },          // 1/4096  = 0.000244140625
  "4.882813E-04": {mbf: "76000000", unpacked: {S:  "1", E: "F6", M: "00800000"},          },          // 1/2048  = 0.00048828125
  "9.765625E-04": {mbf: "77000000", unpacked: {S:  "1", E: "F7", M: "00800000"},          },          // 1/1024  = 0.0009765625
  "1.953125E-03": {mbf: "78000000", unpacked: {S:  "1", E: "F8", M: "00800000"},          },          // 1/512   = 0.001953125
  "3.90625E-03" : {mbf: "79000000", unpacked: {S:  "1", E: "F9", M: "00800000"},          },          // 1/256   = 0.00390625
  ".0078125"    : {mbf: "7A000000", unpacked: {S:  "1", E: "FA", M: "00800000"},          },          // 1/128   = 0.0078125
  ".015625"     : {mbf: "7B000000", unpacked: {S:  "1", E: "FB", M: "00800000"},          },          // 1/64    = 0.015625
  ".03125"      : {mbf: "7C000000", unpacked: {S:  "1", E: "FC", M: "00800000"},          },          // 1/32    = 0.03125
  ".0625"       : {mbf: "7D000000", unpacked: {S:  "1", E: "FD", M: "00800000"},          },          // 1/16    = 0.0625
  ".125"        : {mbf: "7E000000", unpacked: {S:  "1", E: "FE", M: "00800000"},          },          // 1/8     = 0.125
  ".25"         : {mbf: "7F000000", unpacked: {S:  "1", E: "FF", M: "00800000"},          },          // 1/4     = 0.25
  ".5"          : {mbf: "80000000", unpacked: {S:  "1", E: "00", M: "00800000"},          },          // 1/2
  "1!"          : {mbf: "81000000", unpacked: {S:  "1", E: "01", M: "00800000"}, sb: "01" },
  "1.25"        : {mbf: "81200000", unpacked: {S:  "1", E: "01", M: "00A00000"},          },
  "1.5"         : {mbf: "81400000", unpacked: {S:  "1", E: "01", M: "00C00000"},          },
  "2!"          : {mbf: "82000000", unpacked: {S:  "1", E: "02", M: "00800000"}, sb: "02" },
  "2.25"        : {mbf: "82100000", unpacked: {S:  "1", E: "02", M: "00900000"},          },
  "2.5"         : {mbf: "82200000", unpacked: {S:  "1", E: "02", M: "00A00000"},          },
  "3!"          : {mbf: "82400000", unpacked: {S:  "1", E: "02", M: "00C00000"}, sb: "03" },
  "3.25"        : {mbf: "82500000", unpacked: {S:  "1", E: "02", M: "00D00000"},          },
  "3.5"         : {mbf: "82600000", unpacked: {S:  "1", E: "02", M: "00E00000"},          },
  "4!"          : {mbf: "83000000", unpacked: {S:  "1", E: "03", M: "00800000"}, sb: "04" },
  "4.25"        : {mbf: "83080000", unpacked: {S:  "1", E: "03", M: "00880000"},          },
  "4.5"         : {mbf: "83100000", unpacked: {S:  "1", E: "03", M: "00900000"},          },
  "5!"          : {mbf: "83200000", unpacked: {S:  "1", E: "03", M: "00A00000"}, sb: "05" },
  "5.25"        : {mbf: "83280000", unpacked: {S:  "1", E: "03", M: "00A80000"},          },
  "5.5"         : {mbf: "83300000", unpacked: {S:  "1", E: "03", M: "00B00000"},          },
  "6!"          : {mbf: "83400000", unpacked: {S:  "1", E: "03", M: "00C00000"}, sb: "06" },
  "6.25"        : {mbf: "83480000", unpacked: {S:  "1", E: "03", M: "00C80000"},          },
  "6.5"         : {mbf: "83500000", unpacked: {S:  "1", E: "03", M: "00D00000"},          },
  "7!"          : {mbf: "83600000", unpacked: {S:  "1", E: "03", M: "00E00000"}, sb: "07" },
  "7.25"        : {mbf: "83680000", unpacked: {S:  "1", E: "03", M: "00E80000"},          },
  "7.5"         : {mbf: "83700000", unpacked: {S:  "1", E: "03", M: "00F00000"},          },
  "8!"          : {mbf: "84000000", unpacked: {S:  "1", E: "04", M: "00800000"}, sb: "08" },
  "8.25"        : {mbf: "84040000", unpacked: {S:  "1", E: "04", M: "00840000"},          },
  "8.5"         : {mbf: "84080000", unpacked: {S:  "1", E: "04", M: "00880000"},          },
  "9!"          : {mbf: "84100000", unpacked: {S:  "1", E: "04", M: "00900000"}, sb: "09" },
  "9.25"        : {mbf: "84140000", unpacked: {S:  "1", E: "04", M: "00940000"},          },
  "9.5"         : {mbf: "84180000", unpacked: {S:  "1", E: "04", M: "00980000"},          },
  "10!"         : {mbf: "84200000", unpacked: {S:  "1", E: "04", M: "00A00000"}, sb: "0A" },
  "10.25"       : {mbf: "84240000", unpacked: {S:  "1", E: "04", M: "00A40000"},          },
  "10.5"        : {mbf: "84280000", unpacked: {S:  "1", E: "04", M: "00A80000"},          },
  "11!"         : {mbf: "84300000", unpacked: {S:  "1", E: "04", M: "00B00000"}, sb: "0B" },
  "11.25"       : {mbf: "84340000", unpacked: {S:  "1", E: "04", M: "00B40000"},          },
  "11.5"        : {mbf: "84380000", unpacked: {S:  "1", E: "04", M: "00B80000"},          },
  "12!"         : {mbf: "84400000", unpacked: {S:  "1", E: "04", M: "00C00000"}, sb: "0C" },
  "12.25"       : {mbf: "84440000", unpacked: {S:  "1", E: "04", M: "00C40000"},          },
  "12.5"        : {mbf: "84480000", unpacked: {S:  "1", E: "04", M: "00C80000"},          },
  "13!"         : {mbf: "84500000", unpacked: {S:  "1", E: "04", M: "00D00000"}, sb: "0D" },
  "13.25"       : {mbf: "84540000", unpacked: {S:  "1", E: "04", M: "00D40000"},          },
  "13.5"        : {mbf: "84580000", unpacked: {S:  "1", E: "04", M: "00D80000"},          },
  "14!"         : {mbf: "84600000", unpacked: {S:  "1", E: "04", M: "00E00000"}, sb: "0E" },
  "14.25"       : {mbf: "84640000", unpacked: {S:  "1", E: "04", M: "00E40000"},          },
  "14.5"        : {mbf: "84680000", unpacked: {S:  "1", E: "04", M: "00E80000"},          },
  "15!"         : {mbf: "84700000", unpacked: {S:  "1", E: "04", M: "00F00000"}, sb: "0F" },
  "15.25"       : {mbf: "84740000", unpacked: {S:  "1", E: "04", M: "00F40000"},          },
  "15.5"        : {mbf: "84780000", unpacked: {S:  "1", E: "04", M: "00F80000"},          },
  "16!"         : {mbf: "85000000", unpacked: {S:  "1", E: "05", M: "00800000"}, sb: "10" },
  "16.25"       : {mbf: "85020000", unpacked: {S:  "1", E: "05", M: "00820000"},          },
  "16.5"        : {mbf: "85040000", unpacked: {S:  "1", E: "05", M: "00840000"},          },
  // "90!"         : {mbf: "87340000", unpacked: {S:  "1", E: "07", M: "00B40000"}, sb: "5A" },
  // "100!"        : {mbf: "87480000", unpacked: {S:  "1", E: "07", M: "00C80000"}, sb: "64" },
  // "110!"        : {mbf: "875C0000", unpacked: {S:  "1", E: "07", M: "00DC0000"}, sb: "6E" },
  // "120!"        : {mbf: "87700000", unpacked: {S:  "1", E: "07", M: "00F00000"}, sb: "78" },
  // "130!"        : {mbf: "88020000", unpacked: {S:  "1", E: "08", M: "00820000"},          },
}


test('sng.unpack', () => {
  expect(sng.unpack("00000000")).toStrictEqual({S: "0", E: "00", M: "00000000"});
  for (let tst of Object.values(TESTS)) {
    expect(sng.unpack(tst.mbf)).toStrictEqual(tst.unpacked);
  }
});

test('sng.pack', () => {
  expect(sng.pack("0", "00", "00000000")).toBe("00000000");
  for (let tst of Object.values(TESTS)) {
    expect(sng.pack(tst.unpacked.S, tst.unpacked.E, tst.unpacked.M)).toBe(tst.mbf);
  }
});

test('sng.serialize', () => {
  expect(sng.serialize('00000000')).toBe('0');
  // expect(sng.serialize('80000000')).toBe('0.5');
  // expect(sng.serialize('81400000')).toBe('1.5');
  // expect(sng.serialize('9117E880')).toBe('77777');
  // expect(sng.serialize('7E4CCCCD')).toBe('0.2');
});

test('sng.fromSB', () => {
  expect(sng.fromSB('FF')).toBe('81800000');
  expect(sng.fromSB('00')).toBe('00000000');
  expect(sng.fromSB('01')).toBe('81000000');
  for (let tst of Object.values(TESTS)) {
    if (tst.sb) {
      expect(sng.fromSB(tst.sb)).toBe(tst.mbf);
    }
  }
});

test('sng.neg', () => {
  expect(sng.neg("81800000")).toBe("81000000");
  expect(sng.neg("81000000")).toBe("81800000");
  expect(sng.neg("00000000")).toBe("00000000");
});

test('sng.lt', () => {
  expect(sng.lt(TESTS["0!"].mbf, TESTS["0!"].mbf)).toBe('');

})

test('sng.add', () => {
  expect(sng.add(TESTS["0!"].mbf, TESTS["0!"].mbf)).toBe(TESTS["0!"].mbf);
  expect(sng.add(TESTS[".5"].mbf, TESTS[".5"].mbf)).toBe(TESTS["1!"].mbf);
  expect(sng.add(TESTS["1!"].mbf, TESTS[".5"].mbf)).toBe(TESTS["1.5"].mbf);
  expect(sng.add(TESTS["1!"].mbf, TESTS[".25"].mbf)).toBe(TESTS["1.25"].mbf);
  expect(sng.add(TESTS["2.25"].mbf, TESTS["3.25"].mbf)).toBe(TESTS["5.5"].mbf);
  expect(sng.add(TESTS["2.5"].mbf, TESTS["3.5"].mbf)).toBe(TESTS["6!"].mbf);
  expect(sng.add(TESTS["3.90625E-03"].mbf, TESTS["3.90625E-03"].mbf)).toBe(TESTS[".0078125"].mbf);
});

