#!/bin/sh
set -e

npm install

ls

echo "INPUT_DIR: $INPUT_DIR"
echo "CITY_ID: $CITY_ID"

node ./bin/excel2geojson.js $INPUT_DIR
node ./bin/geojson2mbtiles.js $INPUT_DIR $CITY_ID
node ./bin/createTilesJson.js ./$CITY_ID-v1.mbtiles
pmtiles convert ./$CITY_ID-v1.mbtiles ./$CITY_ID-v1.pmtiles

ls $INPUT_DIR
ls

exit 0