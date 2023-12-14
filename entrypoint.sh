#!/bin/sh
set -ex

npm install

node ./bin/excel2geojson.js $INPUT_DIR
node ./bin/geojson2mbtiles.js $INPUT_DIR $CITY_ID
node ./bin/createTilesJson.js ./$CITY_ID-v1.mbtiles

pmtiles convert ./$CITY_ID-v1.mbtiles ./$CITY_ID-v1.pmtiles
pmtiles upload ./$CITY_ID-v1.pmtiles $CITY_ID-v1.pmtiles --bucket=s3://smartcity-data-upload-action-dev

exit 0