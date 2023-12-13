#!/bin/sh
set -e

INPUT_DIR=$1
ACCESS_KEY=$2
AWS_ACCESS_KEY=$3
AWS_SECRET_ACCESS_KEY=$4

echo "INPUT_DIR: $INPUT_DIR"
echo "ACCESS_KEY: $ACCESS_KEY"

npm install

# node_modules が現在のディレクトリにあるか確認
if [ ! -d "./node_modules" ]; then
  echo "node_modules not found"
  exit 1
fi


ls /

node /bin/excel2geojson.js $INPUT_DIR
ls $INPUT_DIR

exit 0