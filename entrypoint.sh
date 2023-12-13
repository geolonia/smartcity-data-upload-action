#!/bin/sh
set -e

INPUT_DIR=$1
ACCESS_KEY=$2
AWS_ACCESS_KEY=$3
AWS_SECRET_ACCESS_KEY=$4

echo "INPUT_DIR: $INPUT_DIR"
echo "ACCESS_KEY: $ACCESS_KEY"

echo $PATH

# Install dependencies
npm install -g csv2geojson
npm install -g klaw

# node_modules が install されている場所を確認
npm root -g

node /bin/excel2geojson.js $INPUT_DIR
ls -l $INPUT_DIR

exit 0