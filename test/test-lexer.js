const {expect, assert} = require('chai');
const {tokenize} = require('../lexer/lexer');


/*
Numeric constants can be integers, single-precision, or double-precision numbers. Integer
constants are stored as whole numbers only. Single-precision numeric constants are stored with 7
digits (although only 6 may be accurate). Double-precision numeric constants are stored with 17
digits of precision, and printed with as many as 16 digits
*/


it('should tokenize positive integers', () => {
  assert.equal(tokenize("0"             ),  ["I16_0000"]        );
  assert.equal(tokenize("16"            ),  ["I16_0010"]        );
  assert.equal(tokenize("32767"         ),  ["I16_7FFF"]        );
  assert.equal(tokenize("1 2   3"       ),  ["I16_007B"]        );
});



it('should tokenize single precision contants', () => {
  /*
  A single-precision constant is any numeric constant with either
  ● Seven or fewer digits
  ● Exponential form using E
  ● A trailing exclamation point (!)
  */
  assert.equal(tokenize("1.0"         ),  ["F32_1.0"]         );
  assert.equal(tokenize("1 2 e 5"     ),  ["F32_12e5"]        );
  assert.equal(tokenize("46.8"        ),  ["F32_1.0"]         );
  assert.equal(tokenize("-1.09E-06"   ),  ["F32_1.0"]         );
  assert.equal(tokenize("3489.0"      ),  ["F32_1.0"]         );
  assert.equal(tokenize("22.5!"       ),  ["F32_1.0"]         );
});


it('should tokenize double precision contants', () => {
  /*
  A double-precision constant is any numeric constant with either
  ● Eight or more digits
  ● Exponential form using D
  ● A trailing number sign (#)
  */
  assert.equal(tokenize("345692811"   ),  ["F64_1.0"]         );
  assert.equal(tokenize("-1.09432D-06"),  ["F64_1.0"]         );
  assert.equal(tokenize("3490.0#"     ),  ["F64_1.0"]         );
  assert.equal(tokenize("7654321.1234"),  ["F64_1.0"]         );
});  


it('should tokenize operators', () => {
  assert.equal(tokenize("+"           ),  ["PLUS"]            );
  assert.equal(tokenize("-"           ),  ["MINUS"]           );
  assert.equal(tokenize("*"           ),  ["MULT"]            );
  assert.equal(tokenize(":"           ),  ["COLON"]           );
  assert.equal(tokenize(":"           ),  ["COLON"]           );
  assert.equal(tokenize(";"           ),  ["SEMICOLON"]       );
  assert.equal(tokenize(","           ),  ["COMMA"]           );
  assert.equal(tokenize("+"           ),  ["PLUS"]            );
  assert.equal(tokenize("-"           ),  ["MINUS"]           );
  assert.equal(tokenize("*"           ),  ["MULT"]            );
  assert.equal(tokenize("/"           ),  ["DIV"]             );
  assert.equal(tokenize("^"           ),  ["POWER"]           );
  assert.equal(tokenize("\\"          ),  ["MOD"]             );
  assert.equal(tokenize("="           ),  ["EQL"]             );
  assert.equal(tokenize("<>"          ),  ["NEQL"]            );
  assert.equal(tokenize("<"           ),  ["LESS"]            );
  assert.equal(tokenize(">"           ),  ["GTR"]             );
  assert.equal(tokenize("<="          ),  ["LEQU"]            );
  assert.equal(tokenize(">="          ),  ["GEQU"]            );
  assert.equal(tokenize("("           ),  ["OPEN_PAR"]        );
  assert.equal(tokenize(")"           ),  ["CLOSE_PAR"]       );
  assert.equal(tokenize("#"           ),  ["HASH"]            );
  assert.equal(tokenize("."           ),  ["DOT"]             );
  
   
  // strange feature of basic lexer: it ignores spaces in numbers
  assert.equal(tokenize(">   ="       ),  ["GEQU"]            );
  assert.equal(tokenize("<   ="       ),  ["LEQU"]            );
});


it('should tokenize strings', () => {
  assert.equal(tokenize("\"Hello\""   ),  ["STR_48656C6C6F"]  );
});

it('should tokenize variables', () => {
  assert.equal(tokenize("i"           ),  ["VAR_I"]           );
  assert.equal(tokenize("i$"          ),  ["VAR_I$"]          );
  assert.equal(tokenize("i%"          ),  ["VAR_I%"]          );
  assert.equal(tokenize("i!"          ),  ["VAR_I!"]          );
  assert.equal(tokenize("i#"          ),  ["VAR_I#"]          );
  assert.equal(tokenize("i100"        ),  ["VAR_I100"]        );
  assert.equal(tokenize("i_100"       ),  ["VAR_I_100"]       );
});


it('should understand rem', () => {
  assert.equal(tokenize("rem Hello"   ),  ["REM", "STR_48656C6C6F"]     );
  assert.equal(tokenize("'Hello"      ),  ["REM", "STR_48656C6C6F"]     );
  assert.equal(tokenize("' Hello"     ),  ["REM", "STR_2048656C6C6F"]   );
});


it('should understand keywords', () => {

});


it('shoud tokenize gw-basic tricks', () => {
  // 11mod4  : I16_11 VAR_mod4
  // 11 mod 4 : I16_11 MOD I16_4
  // 3I$     : I16_3 VAR_I$
  // 3E       : I16_3 VAR_E
  // 3e5     : 300000
});


