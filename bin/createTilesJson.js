const fs = require('fs');
const path = require('path');
const sqlite3 = require('sqlite3');
const { open } = require("sqlite");

async function main() {
  const mbtilesPath = process.argv[2];

  const basename = path.basename(mbtilesPath, ".mbtiles");
  const db = await open({
    filename: mbtilesPath,
    driver: sqlite3.Database,
  });

  const {value} = await db.get("SELECT value FROM metadata WHERE name = 'json'");
  const theJSON = JSON.parse(value);
  delete theJSON['tilestats'];
  
  await db.run(
    "UPDATE metadata SET value = ? WHERE name = 'json'",
    [
      JSON.stringify(theJSON),
    ],
  );

  await db.run(
    "DELETE FROM metadata WHERE name IN ('generator_options', 'generator', 'strategies')",
  );

  const metadataRows = await db.all("SELECT * FROM metadata");
  const metadataOut = {
    "tilejson": "3.0.0",
  };
  for (const row of metadataRows) {
    if (row.name === "json") {
      const json = JSON.parse(row.value);
      for (const key of Object.keys(json)) {
        metadataOut[key] = json[key];
      }
    } else {
      let val = row.value;
      if (row.name === 'bounds' || row.name === 'center') {
        val = row.value.split(",").map((v) => parseFloat(v));
      } else if (row.name === 'minzoom' || row.name === 'maxzoom') {
        val = parseInt(row.value, 10);
      }
      metadataOut[row.name] = val;
    }
  }
  await fs.promises.writeFile(path.join(path.dirname(mbtilesPath), `${basename}.json`), JSON.stringify(metadataOut, null, 2));

  await db.close();
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});