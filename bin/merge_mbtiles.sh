#!/bin/bash -e
#引数を取得
MUNICIPALITY_CODE=${1}

tile-join \
  --force \
  --overzoom \
  --no-tile-size-limit \
  -o ./$MUNICIPALITY_CODE.mbtiles \
  ./smartcity_shape.mbtiles \
  ./smartcity_csv.mbtiles \
  ./smartcity_municipality_mask.mbtiles
