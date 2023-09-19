function toX(s) {
  return s.split('').map(c => c.charCodeAt(0).toString(16).padStart(2, "0").toUpperCase()).join('');
}

module.exports = {toX};
