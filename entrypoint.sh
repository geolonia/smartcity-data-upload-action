#!/bin/sh
set -ex

export AWS_DEFAULT_REGION=ap-northeast-1

npm install

node ./bin/excel2geojson.js $INPUT_DIR
node ./bin/geojson2mbtiles.js $INPUT_DIR $CITY_ID
node ./bin/createTilesJson.js ./$CITY_ID.mbtiles

pmtiles convert ./$CITY_ID.mbtiles ./$CITY_ID.pmtiles

aws s3 cp ./$CITY_ID.pmtiles s3://smartcity-data-upload-action-dev
aws s3 cp ./$CITY_ID.json s3://smartcity-data-upload-action-dev

# 終了ステータスをチェック
if [ $? -eq 0 ]; then
    echo "Upload successful."
else
    echo "Upload failed."
fi