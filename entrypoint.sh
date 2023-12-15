#!/bin/sh
set -ex

export AWS_DEFAULT_REGION=ap-northeast-1

INPUT_DIR_PATH=/github/workspace/$INPUT_DIR

# Excel/CSV を GeoJSON に変換
node ./bin/excel2geojson.js $INPUT_DIR_PATH
# GeoJSON を mbtiles に変換
node ./bin/geojson2mbtiles.js $INPUT_DIR_PATH
# Shapefile を mbtiles に変換
bin/shape2mbtiles.sh $INPUT_DIR_PATH
# 市区町村の形マスクをダウンロードし、mbtiles に変換
bin/mask2mbtiles.sh $MUNICIPALITY_CODE
# mbtiles を統合
bin/merge_mbtiles.sh $MUNICIPALITY_ID

# CatalogJSON を作成
node ./bin/createCatalogJson.js $INPUT_DIR_PATH

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
