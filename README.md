# smartcity-data-upload-action

[![.github/workflows/test.yml](https://github.com/geolonia/smartcity-data-upload-action/actions/workflows/test.yml/badge.svg)](https://github.com/geolonia/smartcity-data-upload-action/actions/workflows/test.yml)

Excel / CSV / GeoJSON から PMTiles と TileJSON を生成します。 生成結果を Geolonia の S3 にデプロイする GitHub Actionです。

## 使用例

```yaml
name: Build and Deploy
on: [push]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: checkout
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-1

      - name: 'Create SmartCity Vector Tile'
        uses: geolonia/smartcity-data-upload-action@main
        with:
          INPUT_DIR: './docs'
          MUNICIPALITY_CODE: 'example-city'
```

## 引数

#### `INPUT_DIR`
- **必須** ベクトルタイルに変換する ファイルが置いてあるディレクトリのパス　（例: `./`）

#### `MUNICIPALITY_CODE`
- **必須** 全国地方公共団体コード (5桁) （例: `37201`）



## 備考
* AWSの認証情報は [aws-actions/configure-aws-credentials@v4](https://github.com/aws-actions/configure-aws-credentials) 等を使用して設定下さい。
* PMTilesと、TileJSONのファイル名は、`MUNICIPALITY_CODE` から生成されます。
* ベクトルタイルのソースレイヤー名は、データ元になるファイル名を使用します。（例： `AED設置場所.xlsx` → `AED設置場所`）
* ベクトルタイルを更新するには データ元のファイルを修正して、コミットすると元のデータが上書きされます。
* Shape の入力にも将来的に対応予定です。

##  開発者向け

ローカルでこの GitHub Action を実行するには以下の手順で作業してください。

```
$ git clone git@github.com:geolonia/smartcity-data-upload-action.git
$ cd geolonia/smartcity-data-upload-action
$ npm install
$ npm run docker:test
```
