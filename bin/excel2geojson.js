const { excel2csv } = require('./excel2csv');
const { writeFile, readFile } = require('fs/promises');
const klaw = require('klaw');
const ConversionError = require('./error');
const csvToGeoJSON = require('./csv-to-geojson');
const convertToUtf8 = require('./convertToUtf8');

const inputDir = process.argv[2];

const excelToGeoJson = async (inputDir) => {
  const promises = [];

  for await (const file of klaw(inputDir, { depthLimit: -1 })) {
    let csvData;

    if (file.path.endsWith(".xlsx")) {
      const excelPath = file.path;
      try {
        csvData = await excel2csv(excelPath);
      } catch (err) {

        if (err.message === "FILE_ENDED") {
          throw new ConversionError("fileEnded", excelPath);
        }

        console.log(err);

        throw new ConversionError("excelToGeoJson", excelPath);
      }
    } else if (file.path.endsWith(".csv")) {
      csvData = await readFile(file.path);
      csvData = convertToUtf8(csvData);

      if (!csvData) {
        console.log(`Error: CSV データ ${file.path} を UTF-8 に変換できませんでした。`);
        continue;
      }

      csvData = csvData.toString('utf-8');
    }

    if (csvData) {
      const geoJsonPath = file.path.replace(/.csv$|.xlsx$/, '.geojson');

      try {

        const geojson = await csvToGeoJSON(csvData);
        if (!geojson) {
          console.log(`Error: CSV データ ${file.path} を GeoJSON に変換できませんでした。`);
          continue;
        }

        await writeFile(geoJsonPath, JSON.stringify(geojson));

      } catch (err) {
        throw new ConversionError("csvToGeoJson", file.path);
      }
    }
  }

  await Promise.all(promises);
}

const main = async (inputDir) => {
  try {
    excelToGeoJson(inputDir);
  } catch (err) {
    if (err instanceof ConversionError) {
      switch (err.conversionType) {
        case "excelToGeoJson":
          throw new Error(`Error: Excel ファイルを ${err.filePath} GeoJSON に変換できませんでした。`);
          break;
        case "fileEnded":
          throw new Error(`Error: データが空になっているか、Excel ファイルが破損している可能性があります。`);
          break;
        case "csvToGeoJson":
          throw new Error(`Error: CSV データ ${err.filePath} を GeoJSON に変換できませんでした。`);
          break;
        default:
          throw new Error(err.message);
      }
    } else {
      throw new Error(err.message);
    }
  }
}

main(inputDir);
