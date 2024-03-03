const fs = require('fs');
const path = require('path');

// ディレクトリのパス
const INPUT_DIR = process.argv[2];

// 相対パスを取得する関数
function getRelativePath(fullPath) {
  let input_dir = INPUT_DIR;
  return path.relative(input_dir, fullPath);
}

// catalog.jsonを生成する関数
function createCatalogJson(dirPath) {
  const items = [];
  const files = fs.readdirSync(dirPath, { withFileTypes: true });
  for (const file of files) {
    if (file.isDirectory()) {
      // ディレクトリの場合, カテゴリを作って、itemsを再起的に追加する

      // 隠しディレクトリはスキップする
      if (file.name.startsWith('.')) {
        continue;
      }

      const subItems = createCatalogJson(path.join(dirPath, file.name));
      if (subItems.length === 0) {
        // カテゴリにアイテムがない場合は、スキップする
        continue;
      }
      const category = {
        type: "Category",
        id: getRelativePath(path.join(dirPath, file.name)),
        name: file.name,
        items: subItems,
      };

      // 同じ id が存在する場合は、スキップする
      const isExist = items.some(item => item.id === category.id);
      if (!isExist) {
        items.push(category);
      }

    } else {

      // CSV/Excelは緯度軽度あればGeoJSONに変換される。
      // GeoJSON, SHP はそのままmbtilesに変換される。
      // そのため、GeoJSON, SHP 以外のファイルは無視しても問題ない。
      const rawExt = path.extname(file.name);
      const ext = rawExt.toLowerCase();
      if (ext !== ".geojson" && ext !== ".shp") {
        continue;
      }

      // ファイルの場合
      const fileNameWithoutExt = path.basename(file.name, rawExt);
      const dataItem = {
        type: "DataItem",
        id: getRelativePath(path.join(dirPath, fileNameWithoutExt)),
        name: fileNameWithoutExt,
        class: fileNameWithoutExt,
        metadata: {}
      };

      // 同じ id が存在する場合は、スキップする
      const isExist = items.some(item => item.id === dataItem.id);
      if (!isExist) {
        items.push(dataItem);
      }
    }
  };

  return items;
}

// catalog.jsonを生成して保存
const catalog = createCatalogJson(INPUT_DIR);
fs.writeFileSync('catalog.json', JSON.stringify(catalog, null, 2));
