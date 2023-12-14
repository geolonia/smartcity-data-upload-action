#!/bin/sh
set -ex

export AWS_DEFAULT_REGION=ap-northeast-1

npm install

node ./bin/excel2geojson.js $INPUT_DIR
node ./bin/geojson2mbtiles.js $INPUT_DIR $MUNICIPALITY_ID
node ./bin/createTilesJson.js ./$MUNICIPALITY_ID.mbtiles

pmtiles convert ./$MUNICIPALITY_ID.mbtiles ./$MUNICIPALITY_ID.pmtiles

aws s3 cp ./$MUNICIPALITY_ID.pmtiles s3://smartcity-data-upload-action-dev
aws s3 cp ./$MUNICIPALITY_ID.json s3://smartcity-data-upload-action-dev

# 終了ステータスをチェック
if [ $? -eq 0 ]; then
    echo "Upload successful."
else
    echo "Upload failed."
fi