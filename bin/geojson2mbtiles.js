const { exec: _exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs');
const klaw = require('klaw');
const path = require('path');
const exec = promisify(_exec);

const inputDir = path.join(__dirname, '..', process.argv[2]);
const CITY_ID = process.argv[3];

const geojsonToMbtiles = async (inputDir) => {
  const mbtilesPaths = [];

  await fs.promises.mkdir("tmp", { recursive: true });
  const tmpdir = await fs.promises.mkdtemp(path.join("tmp", `${CITY_ID}-`));

  for await (const file of klaw(inputDir, { depthLimit: -1 })) {

    if (file.path.endsWith(".geojson")) {
      const fileName = path.basename(file.path, '.geojson');
      console.log(`Processing ${fileName}...`);

      const geojsonPath = file.path;
      const mbtilesPath = path.join(tmpdir, `${fileName}.mbtiles`);

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

  await exec([
    'tile-join',
    '--force',
    '-o', `${CITY_ID}-v1.mbtiles`,
    '--overzoom',
    '--no-tile-size-limit',
    '--tile-stats-values-limit=0',
    ...mbtilesPaths,
  ].map(x => `'${x}'`).join(" "));

  console.log(`Wrote ${CITY_ID}-v1.mbtiles`);

  // tmpdir の中のファイルをlist する
  const files = await fs.promises.readdir(tmpdir);
  console.log(files);
  
  await fs.promises.rm(tmpdir, { recursive: true });
}

const main = async (inputDir) => {
  try {
    geojsonToMbtiles(inputDir);
  } catch (err) {
    console.log(err);
  }
}

main(inputDir);