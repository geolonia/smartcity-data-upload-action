#!/bin/sh
set -e

npm install
ls

echo "INPUT_DIR: $INPUT_DIR"

node ./bin/excel2geojson.js $INPUT_DIR
node ./bin/geojson2mbtiles.js $INPUT_DIR

ls $INPUT_DIR
ls


exit 0