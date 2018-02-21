//
// simple decimal arithmetics
//

const {expect, assert} = require('chai');
const libdecimal = require('../libs/libdecimal/libdecimal');

const {dec, div16} = libdecimal;

it('should parse decimals', () => {
  let d;

  d = {_: "1"};             assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "+1");
  d = {_: "0"};             assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "+0");
  d = {_: "000"};           assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "+0");
  d = {_: "-24"};           assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "-24");
  d = {_: "    -  2   4"};  assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "-24");
  d = {_: "00024"};         assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "+24");
  d = {_: "-00024"};        assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "-24");
  d = {_: "   + 1 0 0 "};   assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "+100");
  d = {_: "-0"};            assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "+0");
  d = {_: "00000100"};      assert.equal(libdecimal.parse(d), 0);       assert.equal(d._, "+100");

  d = {_: "-   z"};         assert.equal(libdecimal.parse(d), 1);
  d = {_: "   +   z"};      assert.equal(libdecimal.parse(d), 1);
  d = {_: "+-2"};           assert.equal(libdecimal.parse(d), 1);
  d = {_: "00000q"};        assert.equal(libdecimal.parse(d), 1);
  d = {_: "   -  00000q"};  assert.equal(libdecimal.parse(d), 1);
  d = {_: "  "};            assert.equal(libdecimal.parse(d), 1);
  d = {_: ""};              assert.equal(libdecimal.parse(d), 1);
});

it('should decrement', () => {
  let d;
  d = {_:"0"};    assert.equal(dec(d),  0);   assert.equal(d._, "-1");
  d = {_:"+0"};   assert.equal(dec(d), 0);    assert.equal(d._, "-1");
  d = {_:"1"};    assert.equal(dec(d),  0);   assert.equal(d._, "+0");
  d = {_:"-1"};   assert.equal(dec(d), 0);    assert.equal(d._, "-2");

  d = {_:"-99999999999999999999"};  assert.equal(dec(d), 0);    assert.equal(d._, "-100000000000000000000");
  d = {_:"100000000000000000000"};  assert.equal(dec(d), 0);    assert.equal(d._, "+99999999999999999999");
  d = {_:" - 5 5 5 5 5 5"};         assert.equal(dec(d), 0);    assert.equal(d._, "-555556");

  d = {_:" -+ 5"};         assert.equal(dec(d), 1);
});

it('should div16', () => {
  let q = {}, r = {};
  div16("0"   , q, r);        assert.equal(q._, "+0");        assert.equal(r._, "+0");
  div16("1"   , q, r);        assert.equal(q._, "+0");        assert.equal(r._, "+1");
  div16("2"   , q, r);        assert.equal(q._, "+0");        assert.equal(r._, "+2");
  div16("15"  , q, r);        assert.equal(q._, "+0");        assert.equal(r._, "+15");
  div16("16"  , q, r);        assert.equal(q._, "+1");        assert.equal(r._, "+0");
  div16("17"  , q, r);        assert.equal(q._, "+1");        assert.equal(r._, "+1");
  div16("-1"  , q, r);        assert.equal(q._, "-1");        assert.equal(r._, "+15");
  div16("-2"  , q, r);        assert.equal(q._, "-1");        assert.equal(r._, "+14");
  div16("-15" , q, r);        assert.equal(q._, "-1");        assert.equal(r._, "+1");
  div16("-16" , q, r);        assert.equal(q._, "-1");        assert.equal(r._, "+0");
  div16("-17" , q, r);        assert.equal(q._, "-2");        assert.equal(r._, "+15");
  div16("10000" , q, r);      assert.equal(q._, "+625");      assert.equal(r._, "+0");
  div16("100000" , q, r);     assert.equal(q._, "+6250");     assert.equal(r._, "+0");
  div16("100000016", q, r);   assert.equal(q._, "+6250001");  assert.equal(r._, "+0");

  div16("100000000000000000000000000000000000000000", q, r);
  assert.equal(q._, "+6250000000000000000000000000000000000000");
  assert.equal(r._, "+0");
  
  div16("100000000000000000000000000000000000000001", q, r);
  assert.equal(q._, "+6250000000000000000000000000000000000000");
  assert.equal(r._, "+1");

  // assert.equal(add("0", "0"), "0");
});


