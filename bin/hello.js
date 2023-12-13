const { readFile } = require('fs/promises');
const path = require('path');
// const csv2geojson = require('csv2geojson');

console.log("hello world")

const main = async () => {

  const filePath = path.join(__dirname, '../docs/aed-locations.csv');

  console.log(filePath);

  const csvData = await readFile(filePath, 'utf-8');
  console.log(csvData);

  // csv2geojson.csv2geojson(
  //   csvData,
  //   {
  //     latfield: 'lat',
  //     lonfield: 'lng',
  //     delimiter: ','
  //   },
  //   async (err, geojson) => {
  //     console.log(geojson);
  //   });
}

main();

