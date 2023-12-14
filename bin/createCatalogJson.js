const fs = require('fs');
const path = require('path');

// ディレクトリのパス
const INPUT_DIR = process.argv[2];

// ファイル名から拡張子を除いた名前を取得する関数
function getFileNameWithoutExtension(fileName) {
  return path.basename(fileName, path.extname(fileName));
}

// 相対パスを取得する関数
function getRelativePath(fullPath) {

  let input_dir = INPUT_DIR;

  // INPUT_DIR に、./ を含む場合は削除する
  if (input_dir.indexOf("./") === 0) {
    input_dir = input_dir.substring(2);
  }
  const index = fullPath.indexOf(input_dir);

  if (index === -1) {
    throw new Error("特定の文字列が見つかりませんでした。");
  } else {
    // markerの後ろの文字列を取得する
    return fullPath.substring(index + input_dir.length + 1);
  }
}

// catalog.jsonを生成する関数
function createCatalogJson(dirPath) {
  const items = [];
  const files = fs.readdirSync(dirPath, { withFileTypes: true });

  files.forEach(file => {
    if (file.isDirectory()) {
      // ディレクトリの場合
      const category = {
        type: "Category",
        id: getRelativePath(path.join(dirPath, file.name)),
        name: file.name,
        items: createCatalogJson(path.join(dirPath, file.name)) // 再帰的に処理
      };

      // 同じ id が存在する場合は、スキップする
      const isExist = items.some(item => item.id === category.id);
      if (!isExist) {
        items.push(category);
      }

    } else {
      // ファイルの場合
      const fileNameWithoutExt = getFileNameWithoutExtension(file.name);
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
  });

  return items;
}

// catalog.jsonを生成して保存
const catalog = createCatalogJson(INPUT_DIR);
fs.writeFileSync('catalog.json', JSON.stringify(catalog, null, 2));
