#!/bin/bash -e
#引数を取得
MUNICIPALITY_ID=${1}

tile-join \
  --force \
  --overzoom \
  --no-tile-size-limit \
  -o ./$MUNICIPALITY_ID.mbtiles \
  ./smartcity_shape.mbtiles \
  ./smartcity_csv.mbtiles \