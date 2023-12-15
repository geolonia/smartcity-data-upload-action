#!/bin/sh
set -ex

export AWS_DEFAULT_REGION=ap-northeast-1

cd /github/workspace

ls
ls /
ls /app

pwd

TMPDIR=$(mktemp -d)
cp -r ./* "$TMPDIR"
cd "$TMPDIR"

ls
ls /
ls /app

# Excel/CSV を GeoJSON に変換
node ./bin/excel2geojson.js $INPUT_DIR
# GeoJSON を mbtiles に変換
node ./bin/geojson2mbtiles.js $INPUT_DIR
# Shapefile を mbtiles に変換
bin/shape2mbtiles.sh $INPUT_DIR
# 市区町村の形マスクをダウンロードし、mbtiles に変換
bin/mask2mbtiles.sh $MUNICIPALITY_CODE
# mbtiles を統合
bin/merge_mbtiles.sh $MUNICIPALITY_ID

# CatalogJSON を作成
node ./bin/createCatalogJson.js $INPUT_DIR

# TilesJSON を作成
node ./bin/createTilesJson.js ./$MUNICIPALITY_ID.mbtiles ./catalog.json

# PMTiles に変換
pmtiles convert ./$MUNICIPALITY_ID.mbtiles ./$MUNICIPALITY_ID.pmtiles

cp ./$MUNICIPALITY_ID.pmtiles /github/workspace
cp ./$MUNICIPALITY_ID.json /github/workspace

aws s3 cp ./$MUNICIPALITY_ID.pmtiles s3://smartcity-data-upload-action-dev
aws s3 cp ./$MUNICIPALITY_ID.json s3://smartcity-data-upload-action-dev

# 終了ステータスをチェック
if [ $? -eq 0 ]; then
    echo "Upload successful."
else
    echo "Upload failed."
fi
