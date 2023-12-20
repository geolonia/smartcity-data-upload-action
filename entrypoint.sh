#!/bin/bash -e

export AWS_DEFAULT_REGION=ap-northeast-1

# この GitHub Action が実行されている workspace は /github/workspace にマウントされている。
INPUT_DIR_PATH=/github/workspace/$INPUT_DIR

# GitHub Action で作られた Docker の workspace は /action/workspace にイメージに保存されている。
cd /action/workspace

# Excel/CSV を GeoJSON に変換
node ./bin/excel2geojson.js $INPUT_DIR_PATH
# GeoJSON を mbtiles に変換
node ./bin/geojson2mbtiles.js $INPUT_DIR_PATH
# Shapefile を mbtiles に変換
bin/shape2mbtiles.sh $INPUT_DIR_PATH
# 市区町村の形マスクをダウンロードし、mbtiles に変換
bin/mask2mbtiles.sh $MUNICIPALITY_CODE
# mbtiles を統合
bin/merge_mbtiles.sh $MUNICIPALITY_CODE

# CatalogJSON を作成
node ./bin/createCatalogJson.js $INPUT_DIR_PATH

# TilesJSON を作成
node ./bin/createTilesJson.js ./$MUNICIPALITY_CODE.mbtiles ./catalog.json

# PMTiles に変換
pmtiles convert ./$MUNICIPALITY_CODE.mbtiles ./$MUNICIPALITY_CODE.pmtiles

cp ./$MUNICIPALITY_CODE.pmtiles /github/workspace
cp ./$MUNICIPALITY_CODE.json /github/workspace

PREFIX="/"

if [[ "$DEPLOY_S3_BUCKET" == "smartcitystandaloneinfra-smartcitystandaloneinfra-w7czadiwetse" ]]; then
  PREFIX="/data/repo:$GITHUB_REPOSITORY:ref:$GITHUB_REF/"
  PMTILES_URL="https://d1ejkd31ehnyp8.cloudfront.net${PREFIX}${MUNICIPALITY_CODE}.pmtiles"
  echo "Uploading to ${PMTILES_URL}"
  echo "pmtiles_url=${PMTILES_URL}" >> $GITHUB_OUTPUT
fi

aws s3 cp ./$MUNICIPALITY_CODE.pmtiles s3://${DEPLOY_S3_BUCKET}${PREFIX}
aws s3 cp ./$MUNICIPALITY_CODE.json s3://${DEPLOY_S3_BUCKET}${PREFIX}

echo "Upload successful."
