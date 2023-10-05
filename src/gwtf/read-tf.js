const  fs = require('fs');
const binary = fs.readFileSync('./B.BAS');

let i = 0;
let v;
let report, hex = '';

const byte = () => { v = binary[i++]; hex += x(v) + ' '; return v;};
const word = () => byte() + 0x100 * byte();
const dword = () => word() + 0x10000 * word();

const single = () => {
  let a0 = byte(), a1 = byte(), a2 = byte(), a3 = byte();
  if (a3 === 0) return 0.0;
  const sign = (a2 & 0x80);
  const exp = (a3 - 2) & 0xFF;
  a3 = (sign | ((exp >> 1) & 0xff)) & 0xFF;
  a2 = ((exp << 7) | (a2 & 0x7F)) & 0xFF;

  let b = new ArrayBuffer(4);
  let i = new Int8Array(b);
  i[0] = a0;
  i[1] = a1;
  i[2] = a2;
  i[3] = a3;


  return x(a0) + x(a1) + x(a2) + x(a3) + '__' + new Float32Array(b)[0];
}
const double = () => x(byte()) + x(byte()) + x(byte()) + x(byte()) + x(byte()) + x(byte()) + x(byte()) + x(byte());
const nextByte = () => (v = binary[i]);

const x = (v) => (v & 0xFF).toString(16).padStart(2, '0');
const xx = (v) => x(v) + x(v >> 8);

// read first byte
if (byte() !== 0xff) {
  console.log('First byte is', v);
  return;
}


const assert = (exp, expl) => {
  if (!exp) {
    console.error('Assertion failed:', expl);
    console.log(hex + '... ' + x(byte()) + ' ' + x(byte()) + ' ' + x(byte()));
    console.log(report);
    process.exit(0);
  }
}


while (true) {
  let offset = word();
  if (offset === 0x0000) break;
  hex = '';
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
        case 0x1D: report += 'SNG_' + single(); break;          // A four-byte single-precision floating-point constant.
        case 0x1E: assert(0, '1E'); break;        // This is not used as a token in a program line
        case 0x1F: report += 'DBL_' + double(); break;          // An eight-byte double-precision floating-point constant.

        case 0x20: report += ' '; break;

        case 0x22: report += '"'; state = "STR"; break;
        case 0x24: report += '$'; break;

        case 0x28: report += '('; break;
        case 0x29: report += ')'; break;

        case 0x2C: report += ','; break;

        case 0x30: // 0
        case 0x31:
        case 0x32:
        case 0x33:
        case 0x34:
        case 0x35:
        case 0x36:
        case 0x37:
        case 0x38:
        case 0x39: report += String.fromCharCode(v); break;    // 9


        case 0x3a:                        // '   (stored as 3A8FD9, ":REM'" but the ":REM" is suppressed when the program is listed.)
          if (nextByte() === 0x8f) {
            assert(byte() === 0x8f, 'NOT 8f');
            assert(byte() === 0xd9, 'NOT d9');
            report += '\'';
            state = 'REM';
          } else {                        // ELSE   (stored as 3AA1, ":ELSE" but the ":" is suppressed when the program is listed.)
            if (nextByte() === 0xA1) {
              byte();
              report += 'ELSE';
            } else {
              report += ':';
            }
          }
          break;
        case 0x3B: report += ';'; break;


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
        case 0x5A: report += String.fromCharCode(v); break;       // Z

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
        case 0xB1:             // WHILE   (stored as B1E9, "WHILE+" but the "+" is suppressed when the program is listed.)
          assert(byte() === 0xE9, `WHILE stored as B1 ${x(v)}`);
          report += 'WHILE';
          break;
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
        case 0xFD:
          switch (byte()) {
            case 0x81: report += 'CVI'; break;
            case 0x82: report += 'CVS'; break;
            case 0x83: report += 'CVD'; break;
            case 0x84: report += 'MKI$'; break;
            case 0x85: report += 'MKS$'; break;
            case 0x86: report += 'MKD$'; break;
            case 0x8B: report += 'EXTERR'; break;
            default: assert(0, `Unknown: FD ${x(v)}`); break;
          }
          break;
        case 0xFE:
          switch (byte()) {
            case 0x81: report += 'FILES'; break;
            case 0x82: report += 'FIELD'; break;
            case 0x83: report += 'SYSTEM'; break;
            case 0x84: report += 'NAME'; break;
            case 0x85: report += 'LSET'; break;
            case 0x86: report += 'RSET'; break;
            case 0x87: report += 'KILL'; break;
            case 0x88: report += 'PUT'; break;
            case 0x89: report += 'GET'; break;
            case 0x8A: report += 'RESET'; break;
            case 0x8B: report += 'COMMON'; break;
            case 0x8C: report += 'CHAIN'; break;
            case 0x8D: report += 'DATE$'; break;
            case 0x8E: report += 'TIME$'; break;
            case 0x8F: report += 'PAINT'; break;
            case 0x90: report += 'COM'; break;
            case 0x91: report += 'CIRCLE'; break;
            case 0x92: report += 'DRAW'; break;
            case 0x93: report += 'PLAY'; break;
            case 0x94: report += 'TIMER'; break;
            case 0x95: report += 'ERDEV'; break;
            case 0x96: report += 'IOCTL'; break;
            case 0x97: report += 'CHDIR'; break;
            case 0x98: report += 'MKDIR'; break;
            case 0x99: report += 'RMDIR'; break;
            case 0x9A: report += 'SHELL'; break;
            case 0x9B: report += 'ENVIRON'; break;
            case 0x9C: report += 'VIEW'; break;
            case 0x9D: report += 'WINDOW'; break;
            case 0x9E: report += 'PMAP'; break;
            case 0x9F: report += 'PALETTE'; break;
            case 0xA0: report += 'LCOPY'; break;
            case 0xA1: report += 'CALLS'; break;
            case 0xA4: report += 'NOISE'; break;    // NOISE   (PCjr only) /     DEBUG   (Sperry PC only)
            case 0xA5: report += 'PCOPY'; break;    // (PCjr or EGA system only)
            case 0xA6: report += 'TERM'; break;     // (PCjr only)
            case 0xA7: report += 'LOCK'; break;
            case 0xA8: report += 'UNLOCK'; break;
            default: assert(0, `Unknown: FE ${x(v)}`); break;
          }
          break;
        case 0xFF:
          switch (byte()) {
            case 0x81: report += 'LEFT$'; break;
            case 0x82: report += 'RIGHT$'; break;
            case 0x83: report += 'MID$'; break;
            case 0x84: report += 'SGN'; break;
            case 0x85: report += 'INT'; break;
            case 0x86: report += 'ABS'; break;
            case 0x87: report += 'SQR'; break;
            case 0x88: report += 'RND'; break;
            case 0x89: report += 'SIN'; break;
            case 0x8A: report += 'LOG'; break;
            case 0x8B: report += 'EXP'; break;
            case 0x8C: report += 'COS'; break;
            case 0x8D: report += 'TAN'; break;
            case 0x8E: report += 'ATN'; break;
            case 0x8F: report += 'FRE'; break;
            case 0x90: report += 'INP'; break;
            case 0x91: report += 'POS'; break;
            case 0x92: report += 'LEN'; break;
            case 0x93: report += 'STR$'; break;
            case 0x94: report += 'VAL'; break;
            case 0x95: report += 'ASC'; break;
            case 0x96: report += 'CHR$'; break;
            case 0x97: report += 'PEEK'; break;
            case 0x98: report += 'SPACE$'; break;
            case 0x99: report += 'OCT$'; break;
            case 0x9A: report += 'HEX$'; break;
            case 0x9B: report += 'LPOS'; break;
            case 0x9C: report += 'CINT'; break;
            case 0x9D: report += 'CSNG'; break;
            case 0x9E: report += 'CDBL'; break;
            case 0x9F: report += 'FIX'; break;
            case 0xA0: report += 'PEN'; break;
            case 0xA1: report += 'STICK'; break;
            case 0xA2: report += 'STRIG'; break;
            case 0xA3: report += 'EOF'; break;
            case 0xA4: report += 'LOC'; break;
            case 0xA5: report += 'LOF'; break;
            default: assert(0, `Unknown: FF ${x(v)}`); break;
          }
          break;
        default:
          assert(0, 'Unknown: ' + x(v));
      }
    } else if (state === 'REM') {
      if (byte() === 0x00) state = 'EOL';
      else report += String.fromCharCode(v);
    } else if (state === "STR") {
      if (byte() === 0x22) { report += '"'; state = "START"; }
      else report += String.fromCharCode(v);
    }
  }

  // console.log(hex);
  console.log(report);
}


