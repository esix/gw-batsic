const  fs = require('fs');
const binary = fs.readFileSync('./B.BAS');

let i = 0;
let v;

const byte = () => (v = binary[i++]);
const word = () => byte() + 0x100 * byte();
const dword = () => word() + 0x100 * word();

const x = (v) => (v & 0xFF).toString(16).padStart(2, '0');
const xx = (v) => x(v) + x(v >> 8);

if (byte() !== 0xff) {
  console.log('First byte is', v);
  return;
}

let report;

const assert = (exp, expl) => {
  if (!exp) {
    console.error('Assertion failed', expl);
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
        case 0x00:
          state = 'EOL';
          break;
        case 0x0B:
          report += '&O' + xx(word());
          break;
        case 0x0C:
          report += '&H' + xx(word());
          break;
        case 0x0D:
          assert(0, '0D');
          break;
        case 0x0E:
          report += 'gosub ' + word();
          break;
        case 0x0F:
          assert(0, '0F');
          break;
        case 0x10:
          assert(0, '10');
          break;
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
        case 0x1D: report += dword(); break;
        case 0x1F: assert(0, '1F'); break;
        case 0x20: report += ' '; break;

        case 0x3a:               // 3A8FD9
          assert(byte() === 0x8f);
          assert(byte() === 0xd9);
          state = 'REM';
          break;
        case 0x8D: report += 'GOSUB'; break;

        default:
          console.log(' 0x' + x(v) + ' ')
          report += ' 0x' + x(v) + ' ';
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


