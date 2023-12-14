#!/bin/sh
set -e

npm install
ls

node ./bin/excel2geojson.js $input_dir
node ./bin/geojson2mbtiles.js $input_dir

ls $input_dir
ls


exit 0