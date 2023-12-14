const { exec: _exec } = require('child_process');
const { promisify } = require('util');
const { writeFile, readFile } = require('fs/promises');
const klaw = require('klaw');
const csv2geojson = require('csv2geojson');
const ConversionError = require('./error');
const path = require('path');
const exec = promisify(_exec);

const inputDir = path.join(__dirname, '..', process.argv[2]);

const geojsonToMbtiles = async (inputDir) => {
  const mbtilesPaths = [];

  for await (const file of klaw(inputDir, { depthLimit: -1 })) {
    let csvData;

    if (file.path.endsWith(".geojson")) {
      const fileName = path.basename(file.path, '.geojson');
      console.log(`Processing ${fileName}...`);

      const geojsonPath = file.path;
      const mbtilesPath = `${fileName}.mbtiles`;

      await exec([
        'tippecanoe',
        '-o', mbtilesPath,
        '-Z0', '-z14',
        '-l', fileName,
        '--cluster-distance=10',
        '--cluster-densest-as-needed',
        '--no-feature-limit',
        '--no-tile-size-limit',
        '--tile-stats-values-limit=0',
        geojsonPath,
      ].map(x => `'${x}'`).join(" "));

      mbtilesPaths.push(mbtilesPath);
    }
  }

  console.log(mbtilesPaths)

}

const main = async (inputDir) => {
  try {
    geojsonToMbtiles(inputDir);
  } catch (err) {
    console.log(err);
  }
}

main(inputDir);