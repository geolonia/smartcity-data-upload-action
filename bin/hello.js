const { readFile } = require('fs/promises');
const path = require('path');

console.log("hello world")

const main = async () => {

  const filePath = path.join(__dirname, '../docs/aed-locations.csv');

  console.log(filePath);

  const csvData = await readFile(filePath, 'utf-8');
  console.log(csvData);
}

main();

