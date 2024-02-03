#!/bin/bash -e
#引数を取得
MUNICIPALITY_CODE=${1}

# mbtilesを統合
# smartcity_shape と smartcity_csv は元データが無ければ生成されないので、存在しない場合は統合しない

MBTILES_LIST=()
if [ -f ./smartcity_shape.mbtiles ]; then
  MBTILES_LIST+=("./smartcity_shape.mbtiles")
fi
if [ -f ./smartcity_csv.mbtiles ]; then
  MBTILES_LIST+=("./smartcity_csv.mbtiles")
fi
if [ -f ./smartcity_municipality_mask.mbtiles ]; then
  MBTILES_LIST+=("./smartcity_municipality_mask.mbtiles")
fi

if [ ${#MBTILES_LIST[@]} -eq 0 ]; then
  echo "No mbtiles to merge."
  exit 1
fi

echo "Merging ${MBTILES_LIST[@]} into ./$MUNICIPALITY_CODE.mbtiles"

tile-join \
  --force \
  --overzoom \
  --no-tile-size-limit \
  -o ./$MUNICIPALITY_CODE.mbtiles \
  "${MBTILES_LIST[@]}"
