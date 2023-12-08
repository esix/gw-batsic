@echo off
if not "%~1"=="" shift & goto :%~1
goto :_start

:check v
  setlocal EnableDelayedExpansion
  set "v=%~1"
  if "!v:~1,1!" neq "" endlocal && exit /B 1
  for %%l in (0 1 2 3 4 5 6 7 8 9 A B C D E F) do (
    if "!v!"=="%%l" endlocal && exit /B 0
  )
  @REM if "!v!" geq "A" if "!v!" leq "F" 
  endlocal && exit /B 1


:serialize v ret
  setlocal EnableDelayedExpansion
  set "v=%~1"
  call :check !v!
  if errorlevel 1 endlocal && exit /B 1
  if "!v!" == "0" set ret=0
  if "!v!" == "1" set ret=1
  if "!v!" == "2" set ret=2
  if "!v!" == "3" set ret=3
  if "!v!" == "4" set ret=4
  if "!v!" == "5" set ret=5
  if "!v!" == "6" set ret=6
  if "!v!" == "7" set ret=7
  if "!v!" == "8" set ret=8
  if "!v!" == "9" set ret=9
  if "!v!" == "A" set ret=10
  if "!v!" == "B" set ret=11
  if "!v!" == "C" set ret=12
  if "!v!" == "D" set ret=13
  if "!v!" == "E" set ret=14
  if "!v!" == "F" set ret=15

  if "!ret!" == "" endlocal && exit /B 1
  endlocal && set "%~2=%ret%" && exit /B 0


:parse dec ret
  setlocal EnableDelayedExpansion
  set "dec=%~1"
  set ret=
  if "!dec!" == "0"  set ret=0
  if "!dec!" == "1"  set ret=1
  if "!dec!" == "2"  set ret=2
  if "!dec!" == "3"  set ret=3
  if "!dec!" == "4"  set ret=4
  if "!dec!" == "5"  set ret=5
  if "!dec!" == "6"  set ret=6
  if "!dec!" == "7"  set ret=7
  if "!dec!" == "8"  set ret=8
  if "!dec!" == "9"  set ret=9
  if "!dec!" == "10" set ret=A
  if "!dec!" == "11" set ret=B
  if "!dec!" == "12" set ret=C
  if "!dec!" == "13" set ret=D
  if "!dec!" == "14" set ret=E
  if "!dec!" == "15" set ret=F

  if "!ret!" == "" endlocal && exit /B 1
  endlocal && set "%~2=%ret%" && exit /B 0


@REM function lt(v1, v2) {
@REM   if (!check(v1)) throw 1;
@REM   if (!check(v2)) throw 1;
@REM   if (v1 < v2) return '1';
@REM   return '';
@REM }


@REM /**
@REM  *
@REM  * @param {string} v
@REM  * @returns {[string, ""|"1"]}
@REM  */
@REM function inc(v) {
@REM   if (!check(v)) throw 1;
@REM   let d = serialize(v);
@REM   /** @type {""|"1"} */
@REM   let c = "";
@REM   d = String((+d) + 1);
@REM   if (d === '16') {
@REM     d = '0';
@REM     c = "1";
@REM   }
@REM   v = parse(d);
@REM   return [v, c];
@REM }


@REM function dec(v) {
@REM   if (!check(v)) throw 1;
@REM   let d = serialize(v), c = '';
@REM   d = String((+d) - 1);
@REM   if (d === '-1') {
@REM     d = '15';
@REM     c = '1';
@REM   }
@REM   v = parse(d);
@REM   return [v, c];
@REM }


@REM /**
@REM  *
@REM  * @param {string} v
@REM  * @param {""|"1"} c
@REM  * @returns {[string, ""|"1"]}
@REM  */
@REM function addc(v, c) {
@REM   if (!check(v)) throw 1;
@REM   if (c) [v, c] = inc(v);
@REM   return [v, c];
@REM }


@REM function add(v1, v2) {
@REM   if (!check(v1)) throw 1;
@REM   if (!check(v2)) throw 1;
@REM   let d1 = serialize(v1), d2 = serialize(v2), c = '';
@REM   let d = String((+d1) + (+d2));
@REM   if ((+d) >= 16) { d = String((+d) - 16); c = '1';}
@REM   let v = parse(d);
@REM   return [v, c];
@REM }


@REM function subc(v, c) {
@REM   if (!check(v)) throw 1;
@REM   if (c) [v, c] = dec(v);
@REM   return [v, c];
@REM }


@REM function sub(v1, v2) {
@REM   if (!check(v1)) throw 1;
@REM   if (!check(v2)) throw 1;
@REM   let d1 = serialize(v1), d2 = serialize(v2), c = '';
@REM   let d = String((+d1) - (+d2));
@REM   if ((+d) < 0) { d = String((+d) + 16); c = '1';}
@REM   let v = parse(d);
@REM   return [v, c];
@REM }


@REM function mul(v1, v2) {
@REM   if (!check(v1)) throw 1;
@REM   if (!check(v2)) throw 1;
@REM   let d1 = serialize(v1), d2 = serialize(v2), c = '';
@REM   let d = String((+d1) * (+d2));
@REM   let h = parse(String(Math.floor((+d) / 16))), l = parse(String((+d) % 16));
@REM   return `${h}${l}`;
@REM }


@REM function toBin(v) {
@REM   let ret = '';
@REM   if (!check(v)) throw 1;
@REM   if (v === '0') ret = '0000';
@REM   if (v === '1') ret = '0001';
@REM   if (v === '2') ret = '0010';
@REM   if (v === '3') ret = '0011';
@REM   if (v === '4') ret = '0100';
@REM   if (v === '5') ret = '0101';
@REM   if (v === '6') ret = '0110';
@REM   if (v === '7') ret = '0111';
@REM   if (v === '8') ret = '1000';
@REM   if (v === '9') ret = '1001';
@REM   if (v === 'A') ret = '1010';
@REM   if (v === 'B') ret = '1011';
@REM   if (v === 'C') ret = '1100';
@REM   if (v === 'D') ret = '1101';
@REM   if (v === 'E') ret = '1110';
@REM   if (v === 'F') ret = '1111';
@REM   return ret;
@REM }


@REM function fromBin(b) {
@REM   let ret = '';
@REM   if (b === '0000') ret = '0';
@REM   if (b === '0001') ret = '1';
@REM   if (b === '0010') ret = '2';
@REM   if (b === '0011') ret = '3';
@REM   if (b === '0100') ret = '4';
@REM   if (b === '0101') ret = '5';
@REM   if (b === '0110') ret = '6';
@REM   if (b === '0111') ret = '7';
@REM   if (b === '1000') ret = '8';
@REM   if (b === '1001') ret = '9';
@REM   if (b === '1010') ret = 'A';
@REM   if (b === '1011') ret = 'B';
@REM   if (b === '1100') ret = 'C';
@REM   if (b === '1101') ret = 'D';
@REM   if (b === '1110') ret = 'E';
@REM   if (b === '1111') ret = 'F';
@REM   return ret;
@REM }


@REM function not(v) {
@REM   if (!check(v)) throw 1;
@REM   let bin = toBin(v);
@REM   let r = '';
@REM   if (bin.substr(0, 1) === '1') r += '0'; else r += '1';
@REM   if (bin.substr(1, 1) === '1') r += '0'; else r += '1';
@REM   if (bin.substr(2, 1) === '1') r += '0'; else r += '1';
@REM   if (bin.substr(3, 1) === '1') r += '0'; else r += '1';
@REM   return fromBin(r);
@REM }


@REM function _binAnd(b1, b2) {
@REM   if (b1 === '1' && b2 === '1') return '1';
@REM   return '0';
@REM }


@REM function _binOr(b1, b2) {
@REM   if (b1 === '1' || b2 === '1') return '1';
@REM   return '0';
@REM }


@REM function and(v1, v2) {
@REM   if (!check(v1)) throw 1;
@REM   if (!check(v2)) throw 1;
@REM   let b1 = toBin(v1), b2 = toBin(v2);
@REM   return fromBin(
@REM       _binAnd(b1[0], b2[0]) +
@REM       _binAnd(b1[1], b2[1]) +
@REM       _binAnd(b1[2], b2[2]) +
@REM       _binAnd(b1[3], b2[3]));
@REM }


@REM function or(v1, v2) {
@REM   if (!check(v1)) throw 1;
@REM   if (!check(v2)) throw 1;
@REM   let b1 = toBin(v1), b2 = toBin(v2);
@REM   return fromBin(
@REM       _binOr(b1[0], b2[0]) +
@REM       _binOr(b1[1], b2[1]) +
@REM       _binOr(b1[2], b2[2]) +
@REM       _binOr(b1[3], b2[3]));
@REM }


@REM // bit scan reverse
@REM function bsr(v) {
@REM   if (!check(v)) throw 1;
@REM   let b = toBin(v);
@REM   if (b.substr(0, 1) === '1') return '4';
@REM   if (b.substr(1, 1) === '1') return '3';
@REM   if (b.substr(2, 1) === '1') return '2';
@REM   if (b.substr(3, 1) === '1') return '1';
@REM   return '0';
@REM }


:_start
echo _start@xhalf.bat

