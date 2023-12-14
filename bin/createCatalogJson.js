const fs = require('fs');
const path = require('path');

// ディレクトリのパスを引数から取得
const directoryPath = process.argv[2];

// catalog.jsonを生成する関数
function createCatalogJson(dirPath) {
  const items = [];
  const files = fs.readdirSync(dirPath, { withFileTypes: true });

  files.forEach(file => {
    if (file.isDirectory()) {
      // ディレクトリの場合
      const category = {
        type: "Category",
        id: file.name,
        name: file.name,
        items: createCatalogJson(path.join(dirPath, file.name)) // 再帰的に処理
      };
      items.push(category);
    } else {
      // ファイルの場合
      const dataItem = {
        type: "DataItem",
        id: path.join(dirPath, file.name),
        name: path.basename(file.name, path.extname(file.name)),
        class: path.basename(file.name, path.extname(file.name)),
        metadata: {}
      };
      items.push(dataItem);
    }
  });

  return items;
}

// catalog.jsonを生成して保存
const catalog = createCatalogJson(directoryPath);
fs.writeFileSync('catalog.json', JSON.stringify(catalog, null, 2));
