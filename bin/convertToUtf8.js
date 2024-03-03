const iconv = require('iconv-lite');
const jschardet = require('jschardet');

const convertToUtf8 = (content) => {
  const detectedEncoding = jschardet.detect(content).encoding;

  console.log(`Detected encoding: ${detectedEncoding}`);

  if (detectedEncoding === 'SHIFT_JIS') {
    return iconv.decode(content, 'Shift_JIS');
  }

  // UTF-8 と判定された場合はそのまま返す
  if (detectedEncoding === 'UTF-8' || detectedEncoding === 'ascii') {
    return content;
  }

  return false;
}

module.exports = convertToUtf8;
