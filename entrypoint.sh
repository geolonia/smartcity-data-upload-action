#!/bin/sh
set -e

npm install

ls

echo "INPUT_DIR: $INPUT_DIR"

find  ./ -name "napi-v6-linux-glibc-arm64/";

node ./bin/excel2geojson.js $INPUT_DIR
node ./bin/geojson2mbtiles.js $INPUT_DIR
node ./bin/createTilesJson.js ./smart-city-data-v1.mbtiles

ls $INPUT_DIR
ls

exit 0