#!/bin/sh
set -e

npm install
find . -name "node_modules"

node ./bin/hello.js


# INPUT_DIR=$1
# ACCESS_KEY=$2
# AWS_ACCESS_KEY=$3
# AWS_SECRET_ACCESS_KEY=$4

# echo "INPUT_DIR: $INPUT_DIR"
# echo "ACCESS_KEY: $ACCESS_KEY"

# chmod +x $INPUT_DIR/aed-locations.xlsx
# chmod +x $INPUT_DIR/aed-locations.csv
# npm install

# echo $INPUT_DIR
# pwd
# ls docs

# node ./bin/excel2geojson.js $INPUT_DIR

exit 0