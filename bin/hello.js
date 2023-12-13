const { readFile } = require('fs/promises');
const path = require('path');
const csv2geojson = require('csv2geojson');
let inputDir = process.argv[2];

console.log("hello world")

const main = async () => {

  const filePath = path.join(__dirname, '..', inputDir, 'aed-locations.csv');

  console.log(filePath);

  const csvData = await readFile(filePath, 'utf-8');
  console.log(csvData);

  csv2geojson.csv2geojson(
    csvData,
    {
      latfield: 'latitude',
      lonfield: 'longitude',
      delimiter: ','
    },
    async (err, geojson) => {
      console.log(geojson);
    });
}

main();

