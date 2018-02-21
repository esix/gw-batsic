const {expect, assert} = require('chai');
const libbin = require('../libs/libbin/libbin');

const {
  dec_to_x8, 
  dec_to_x16, 
  dec_to_x32, 
  dec_to_x64, 
  u_to_dec, 
  s_to_dec,
} = libbin;

it('should parse one byte decimal integer', () => {
  let result = {}, err;
  err = dec_to_x8("0"             , result);    assert.equal(err, 0);    assert.equal(result._, "00");
  err = dec_to_x8("1"             , result);    assert.equal(err, 0);    assert.equal(result._, "01");
  err = dec_to_x8("2"             , result);    assert.equal(err, 0);    assert.equal(result._, "02");
  err = dec_to_x8("10"            , result);    assert.equal(err, 0);    assert.equal(result._, "0A");
  err = dec_to_x8("+10"           , result);    assert.equal(err, 0);    assert.equal(result._, "0A");
  err = dec_to_x8("127"           , result);    assert.equal(err, 0);    assert.equal(result._, "7F");
  err = dec_to_x8("128"           , result);    assert.equal(err, 0);    assert.equal(result._, "80");
  err = dec_to_x8("-1"            , result);    assert.equal(err, 0);    assert.equal(result._, "FF");
  err = dec_to_x8("-2"            , result);    assert.equal(err, 0);    assert.equal(result._, "FE");
  err = dec_to_x8("-128"          , result);    assert.equal(err, 0);    assert.equal(result._, "80");
  err = dec_to_x8("-127"          , result);    assert.equal(err, 0);    assert.equal(result._, "81");
  err = dec_to_x8("255"           , result);    assert.equal(err, 0);    assert.equal(result._, "FF");
  err = dec_to_x8("256"           , result);    assert.equal(err, 1);
  err = dec_to_x8("-129"          , result);    assert.equal(err, 1);
  err = dec_to_x8("9999999999999" , result);    assert.equal(err, 1);
  err = dec_to_x8("-999999999999" , result);    assert.equal(err, 1);
  err = dec_to_x8("foo"           , result);    assert.equal(err, 2);
  err = dec_to_x8(""              , result);    assert.equal(err, 2);
  err = dec_to_x8(" "             , result);    assert.equal(err, 2);
});



it('should parse two bytes decimal integer', () => {
  let result = {}, err;
  err = dec_to_x16("0"             , result);    assert.equal(err, 0);    assert.equal(result._, "0000");
  err = dec_to_x16("1"             , result);    assert.equal(err, 0);    assert.equal(result._, "0001");
  err = dec_to_x16("2"             , result);    assert.equal(err, 0);    assert.equal(result._, "0002");
  err = dec_to_x16("10"            , result);    assert.equal(err, 0);    assert.equal(result._, "000A");
  err = dec_to_x16("+10"           , result);    assert.equal(err, 0);    assert.equal(result._, "000A");
  err = dec_to_x16("127"           , result);    assert.equal(err, 0);    assert.equal(result._, "007F");
  err = dec_to_x16("128"           , result);    assert.equal(err, 0);    assert.equal(result._, "0080");
  err = dec_to_x16("-1"            , result);    assert.equal(err, 0);    assert.equal(result._, "FFFF");
  err = dec_to_x16("-2"            , result);    assert.equal(err, 0);    assert.equal(result._, "FFFE");
  err = dec_to_x16("-128"          , result);    assert.equal(err, 0);    assert.equal(result._, "FF80");
  err = dec_to_x16("-127"          , result);    assert.equal(err, 0);    assert.equal(result._, "FF81");
  err = dec_to_x16("255"           , result);    assert.equal(err, 0);    assert.equal(result._, "00FF");
  err = dec_to_x16("256"           , result);    assert.equal(err, 0);    assert.equal(result._, "0100");
  err = dec_to_x16("32767"         , result);    assert.equal(err, 0);    assert.equal(result._, "7FFF");
  err = dec_to_x16("32768"         , result);    assert.equal(err, 0);    assert.equal(result._, "8000");
  err = dec_to_x16("-32768"        , result);    assert.equal(err, 0);    assert.equal(result._, "8000");
  err = dec_to_x16("-32767"        , result);    assert.equal(err, 0);    assert.equal(result._, "8001");
  err = dec_to_x16("9999999999999" , result);    assert.equal(err, 1);
  err = dec_to_x16("-999999999999" , result);    assert.equal(err, 1);
  err = dec_to_x16("foo"           , result);    assert.equal(err, 2);
  err = dec_to_x16(""              , result);    assert.equal(err, 2);
  err = dec_to_x16(" "             , result);    assert.equal(err, 2);
});

