


function StrLen(s) {
  return s.length;
}


function str2hex(StrVar) {
  let result = "";
  for (let i = 0; i < StrLen(StrVar); i++) {
    result += StrVar.charCodeAt(i).toString(16);
  }
  return result.toUpperCase();
}

module.exports = {
  StrLen,
  str2hex,
};
