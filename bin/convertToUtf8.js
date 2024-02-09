const iconv = require('iconv-lite');
const jschardet = require('jschardet');

const convertToUtf8 = (content) => {
  const detectedEncoding = jschardet.detect(content).encoding;

  if (detectedEncoding === 'SHIFT_JIS') {
    return iconv.decode(content, 'Shift_JIS');
  }

  return content;
}

module.exports = convertToUtf8;
