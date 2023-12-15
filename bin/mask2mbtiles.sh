#!/bin/bash -e

MUNICIPALITY_CODE="${1}"

curl 'https://geolonia.github.io/smartcity-sdk/municipality_polygons/'${MUNICIPALITY_CODE}'.ndgeojson' -o ./smartcity_municipality_mask.ndgeojson
tippecanoe \
  -Z0 -z14 \
  --force \
  --no-tile-size-limit \
  --layer="municipality_area" \
  -o ./smartcity_municipality_mask.mbtiles \
  ./smartcity_municipality_mask.ndgeojson
