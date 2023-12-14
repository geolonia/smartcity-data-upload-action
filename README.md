# smartcity-data-upload-action

[![.github/workflows/test.yml](https://github.com/geolonia/smartcity-data-upload-action/actions/workflows/test.yml/badge.svg)](https://github.com/geolonia/smartcity-data-upload-action/actions/workflows/test.yml)

Excel / CSV / GeoJSON を一つの PMTiles 変換し TileJSON を生成し、Geolonia の S3 にデプロイする GitHub Actionです。

## Example usage

```yaml
name: Build and Deploy
on: [push]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: checkout
        uses: actions/checkout@v3

      - name: 'Create SmartCity Vector Tile'
        uses: geolonia/smartcity-data-upload-action@main
        with:
          INPUT_DIR: './docs'
          CITY_ID: 'example-city'
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

## 引数

#### `INPUT_DIR`
- **必須** ベクトルタイルに変換する ファイルが置いてあるディレクトリのパス　（例: `./`）

#### `CITY_ID`
- **必須** ユニークな市区町村の値。ファイル名として使用されます。（例： `takamatsu-city`から `takamatsu-city.mbtiles`、`takamatsu-city.json`というファイルが生成されます）

#### `AWS_ACCESS_KEY_ID`
- **必須** Geoonia の AWSアクセスキー。GitHub Secrets 等を使用して指定してください。

#### `AWS_SECRET_ACCESS_KEY`
- **必須** Geolonia の AWSシークレットアクセスキー。GitHub Secrets 等を使用して指定してください。

## 備考
* PMTilesと、TileJSONのファイル名は、`CITY_ID` から生成されます。
* ベクトルタイルのソースレイヤー名は、データ元になるファイル名を使用します。（例： `aed_locations.xlsx` → `aed_locations`）
* ベクトルタイルを更新するには データ元のファイルを修正して、コミットすると元のデータが上書きされます。

##  開発者向け

ローカルでこの GitHub Action を実行するには以下の手順で作業してください。

```
$ git clone git@github.com:geolonia/smartcity-data-upload-action.git
$ cd geolonia/smartcity-data-upload-action
$ npm install
$ npm run docker:test
```
