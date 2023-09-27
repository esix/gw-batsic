const  fs = require('fs');
const binary = fs.readFileSync('./B.BAS');

let i = 0;
let v;

const byte = () => (v = binary[i++]);
const word = () => byte() + 0x100 * byte();
const dword = () => word() + 0x10000 * word();
const qword = () => dword() + 0x100000000 * dword();

const single = () => dword();
const double = () => qword();                               // TODO
const nextByte = () => (v = binary[i]);

const x = (v) => (v & 0xFF).toString(16).padStart(2, '0');
const xx = (v) => x(v) + x(v >> 8);

if (byte() !== 0xff) {
  console.log('First byte is', v);
  return;
}

let report;

const assert = (exp, expl) => {
  if (!exp) {
    console.error('Assertion failed:', expl);
    console.log(report);
    process.exit(0);
  }
}


while (true) {
  let offset = word();
  if (offset === 0x0000) break;
  const lineNum = word();
  report = lineNum + ' ';

  let state = 'START';
  while (state !== 'EOL') {
    if (state === 'START') {
      switch (byte()) {
        case 0x00: state = 'EOL'; break;                            // The end of the program line.

        case 0x0B: report += '&O' + xx(word()); break;
        case 0x0C: report += '&H' + xx(word()); break;
        case 0x0E: report += word(); break;                 // A line number before being used by GOTO or GOSUB or in a saved tokenised program.
        case 0x0F: report += byte(); break;               // A one-byte integer constant, 11 to 255.
        case 0x10: assert(0, '10'); break;              // Never used as a token in a line. Flags constant no longer being processed. See 1E.
        case 0x11: report += '0'; break;
        case 0x12: report += '1'; break;
        case 0x13: report += '2'; break;
        case 0x14: report += '3'; break;
        case 0x15: report += '4'; break;
        case 0x16: report += '5'; break;
        case 0x17: report += '6'; break;
        case 0x18: report += '7'; break;
        case 0x19: report += '8'; break;
        case 0x1A: report += '9'; break;
        case 0x1B: report += '10'; break;
        case 0x1C: report += word(); break;
        case 0x1D: report += single(); break;          // A four-byte single-precision floating-point constant.
        case 0x1E: assert(0, '1E'); break;        // This is not used as a token in a program line
        case 0x1F: report += double(); break;          // An eight-byte double-precision floating-point constant.

        case 0x20: report += ' '; break;

        case 0x2C: report += ','; break;

        case 0x3a:                        // '   (stored as 3A8FD9, ":REM'" but the ":REM" is suppressed when the program is listed.)
          if (nextByte() === 0x8f) {
            assert(byte() === 0x8f, 'NOT 8f');
            assert(byte() === 0xd9, 'NOT d9');
            report += '\'';
            state = 'REM';
          } else {                        // ELSE   (stored as 3AA1, ":ELSE" but the ":" is suppressed when the program is listed.)
            if (nextByte() === 0xA1) byte();      // NO such byte in tests???
            report += ':';
          }
          break;

        case 0x41:    // A
        case 0x42:
        case 0x43:
        case 0x44:
        case 0x45:
        case 0x46:
        case 0x47:
        case 0x48:
        case 0x49:
        case 0x4A:
        case 0x4B:
        case 0x4C:
        case 0x4D:
        case 0x4E:
        case 0x4F:
        case 0x50:
        case 0x51:
        case 0x52:
        case 0x53:
        case 0x54:
        case 0x55:
        case 0x56:
        case 0x57:
        case 0x58:
        case 0x59:
        case 0x5A:    // Z
          report += String.fromCharCode(v); break;

        case 0x81: report += 'END'; break;
        case 0x82: report += 'FOR'; break;
        case 0x83: report += 'NEXT'; break;
        case 0x84: report += 'DATA'; break;
        case 0x85: report += 'INPUT'; break;
        case 0x86: report += 'DIM'; break;
        case 0x87: report += 'READ'; break;
        case 0x88: report += 'LET'; break;
        case 0x89: report += 'GOTO'; break;
        case 0x8A: report += 'RUN'; break;
        case 0x8B: report += 'IF'; break;
        case 0x8C: report += 'RESTORE'; break;
        case 0x8D: report += 'GOSUB'; break;
        case 0x8E: report += 'RETURN'; break;
        case 0x8F: report += 'REM'; break;
        case 0x90: report += 'STOP'; break;
        case 0x91: report += 'PRINT'; break;
        case 0x92: report += 'CLEAR'; break;
        case 0x93: report += 'LIST'; break;
        case 0x94: report += 'NEW'; break;
        case 0x95: report += 'ON'; break;
        case 0x96: report += 'WAIT'; break;
        case 0x97: report += 'DEF'; break;
        case 0x98: report += 'POKE'; break;
        case 0x99: report += 'CONT'; break;
        case 0x9A: assert(0, '(9A - Undefined)'); break;
        case 0x9B: assert(0, '(9B - Undefined)'); break;
        case 0x9C: report += 'OUT'; break;
        case 0x9D: report += 'LPRINT'; break;
        case 0x9E: report += 'LLIST'; break;
        case 0x9F: assert(0, '(9F - Undefined)'); break;
        case 0xA0: report += 'WIDTH'; break;
        case 0xA1: assert(0, '3A'); break;  // ELSE   (stored as 3AA1, ":ELSE" but the ":" is suppressed when the program is listed.)
        case 0xA2: report += 'TRON'; break;
        case 0xA3: report += 'TROFF'; break;
        case 0xA4: report += 'SWAP'; break;
        case 0xA5: report += 'ERASE'; break;
        case 0xA6: report += 'EDIT'; break;
        case 0xA7: report += 'ERROR'; break;
        case 0xA8: report += 'RESUME'; break;
        case 0xA9: report += 'DELETE'; break;
        case 0xAA: report += 'AUTO'; break;
        case 0xAB: report += 'RENUM'; break;
        case 0xAC: report += 'DEFSTR'; break;
        case 0xAD: report += 'DEFINT'; break;
        case 0xAE: report += 'DEFSNG'; break;
        case 0xAF: report += 'DEFDBL'; break;
        case 0xB0: report += 'LINE'; break;
        case 0xB1: assert(0, 'B1'); break;            // WHILE   (stored as B1E9, "WHILE+" but the "+" is suppressed when the program is listed.)
        case 0xB2: report += 'WEND'; break;
        case 0xB3: report += 'CALL'; break;
        case 0xB4: assert(0, '(B4 - Undefined)'); break;
        case 0xB5: assert(0, '(B5 - Undefined)'); break;
        case 0xB6: assert(0, '(B6 - Undefined)'); break;
        case 0xB7: report += 'WRITE'; break;
        case 0xB8: report += 'OPTION'; break;
        case 0xB9: report += 'RANDOMIZE'; break;
        case 0xBA: report += 'OPEN'; break;
        case 0xBB: report += 'CLOSE'; break;
        case 0xBC: report += 'LOAD'; break;
        case 0xBD: report += 'MERGE'; break;
        case 0xBE: report += 'SAVE'; break;
        case 0xBF: report += 'COLOR'; break;
        case 0xC0: report += 'CLS'; break;
        case 0xC1: report += 'MOTOR'; break;
        case 0xC2: report += 'BSAVE'; break;
        case 0xC3: report += 'BLOAD'; break;
        case 0xC4: report += 'SOUND'; break;
        case 0xC5: report += 'BEEP'; break;
        case 0xC6: report += 'PSET'; break;
        case 0xC7: report += 'PRESET'; break;
        case 0xC8: report += 'SCREEN'; break;
        case 0xC9: report += 'KEY'; break;
        case 0xCA: report += 'LOCATE'; break;
        case 0xCB: assert(0, '(CB - Undefined)'); break;
        case 0xCC: report += 'TO'; break;
        case 0xCD: report += 'THEN'; break;
        case 0xCE: report += 'TAB('; break;       // (note that the following "(" is part of the keyword with no intervening space. That's why "TAB   (..." will not work.)
        case 0xCF: report += 'STEP'; break;
        case 0xD0: report += 'USR'; break;
        case 0xD1: report += 'FN'; break;
        case 0xD2: report += 'SPC('; break;       // (note that the following "(" is part of the keyword with no intervening space. That's why "SPC   (..." will not work.)
        case 0xD3: report += 'NOT'; break;
        case 0xD4: report += 'ERL'; break;
        case 0xD5: report += 'ERR'; break;
        case 0xD6: report += 'STRING$'; break;
        case 0xD7: report += 'USING'; break;
        case 0xD8: report += 'INSTR'; break;
        case 0xD9: assert(0, 'D9'); break;        // '   (stored as 3A8FD9, ":REM'" but the ":REM" is suppressed when the program is listed.)
        case 0xDA: report += 'VARPTR'; break;
        case 0xDB: report += 'CSRLIN'; break;
        case 0xDC: report += 'POINT'; break;
        case 0xDD: report += 'OFF'; break;
        case 0xDE: report += 'INKEY$'; break;
        case 0xDF: assert(0, '(DF - Undefined)'); break;
        case 0xE0: assert(0, '(E0 - Undefined)'); break;
        case 0xE1: assert(0, '(E1 - Undefined)'); break;
        case 0xE2: assert(0, '(E2 - Undefined)'); break;
        case 0xE3: assert(0, '(E3 - Undefined)'); break;
        case 0xE4: assert(0, '(E4 - Undefined)'); break;
        case 0xE5: assert(0, '(E5 - Undefined)'); break;
        case 0xE6: report += '>'; break;
        case 0xE7: report += '='; break;
        case 0xE8: report += '<'; break;
        case 0xE9: report += '+'; break;
        case 0xEA: report += '-'; break;
        case 0xEB: report += '*'; break;
        case 0xEC: report += '/'; break;
        case 0xED: report += '^'; break;
        case 0xEE: report += 'AND'; break;
        case 0xEF: report += 'OR'; break;
        case 0xF0: report += 'XOR'; break;
        case 0xF1: report += 'EQV'; break;
        case 0xF2: report += 'IMP'; break;
        case 0xF3: report += 'MOD'; break;
        case 0xF4: report += '\\'; break;
        case 0xF5: assert(0, '(F5 - Undefined)'); break;
        case 0xF6: assert(0, '(F6 - Undefined)'); break;
        case 0xF7: assert(0, '(F7 - Undefined)'); break;
        case 0xF8: assert(0, '(F8 - Undefined)'); break;
        case 0xF9: assert(0, '(F9 - Undefined)'); break;
        case 0xFA: assert(0, '(FA - Undefined)'); break;
        case 0xFB: assert(0, '(FB - Undefined)'); break;
        case 0xFC: assert(0, '(FC - Undefined)'); break;

        default:
          assert(0, 'Unknown byte ' + x(v));
      }
    } else if (state === 'REM') {
      if (byte() === 0x00) {
        state = 'EOL';
      } else {
        report += String.fromCharCode(v);
      }
    }
  }

  console.log(report);
}


