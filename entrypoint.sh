#!/bin/sh
set -e

INPUT_DIR=$1
ACCESS_KEY=$2
AWS_ACCESS_KEY=$3
AWS_SECRET_ACCESS_KEY=$4


npm install

node ./bin/excel2geojson.js $INPUT_DIR
# node ./bin/geojson2mbtiles.js $INPUT_DIR

ls $INPUT_DIR
# geojson を 表示
cat ./docs/aed-locations-csv.geojson | jq
cat ./docs/aed-locations-xlsx.geojson | jq

exit 0