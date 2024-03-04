const Papa = require('papaparse');

const csvToGeoJSON = (csvString) => {
  return new Promise((resolve, reject) => {
    Papa.parse(csvString, {
      header: true,
      skipEmptyLines: true,
      complete: (results) => {
        const latHeaders = [
          /緯度/,
          /lat(itude)?/i,
        ];
        const lonHeaders = [
          /経度/,
          /lon(gitude)?/i,
          /lng/i,
        ];

        let latField, lonField;

        const headers = results.meta.fields;

        // 緯度・経度のヘッダー名を判定
        for (const field of headers) {

          if (typeof latField === 'undefined' && latHeaders.some((regex) => regex.test(field))) {
            latField = field;
          }
          if (typeof lonField === 'undefined' && lonHeaders.some((regex) => regex.test(field))) {
            lonField = field;
          }
        }

        if (!latField || !lonField) {
          console.log("緯度または経度の列が見つかりません。");
          resolve(false);
        }

        let out = '{"type":"FeatureCollection","features":[\n';

        let recordedFeatures = 0;
        for (const record of results.data) {
          const latValue = parseFloat(record[latField]);
          const lonValue = parseFloat(record[lonField]);

          if (isNaN(latValue) || isNaN(lonValue)) {
            return null;
          }

          // recordから緯度・経度のフィールドを削除
          delete record[latField];
          delete record[lonField];

          const featureStr = JSON.stringify({
            type: "Feature",
            geometry: {
              type: "Point",
              coordinates: [lonValue, latValue]
            },
            properties: record
          });
          recordedFeatures += 1;
          out += featureStr + ",\n";
        }

        //geojson の features が空の場合はエラー
        if (recordedFeatures === 0) {
          console.log("緯度・経度の列に数値以外の値が含まれているか、データが空です。");
          resolve(false);
        }

        // remove trailing newline and comma, then append last newline with closing bracket
        out = out.slice(0, -2) + "\n]}\n";

        resolve(out);
      },
      error: (err) => {
        reject(err);
      }
    });
  });
}

module.exports = csvToGeoJSON;
