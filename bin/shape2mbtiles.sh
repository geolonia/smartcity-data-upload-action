#!/bin/bash -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

input=${1}
outdir=$(mktemp -d)

echo "Output: $outdir"

sed='sed'
# if gsed is available, use it instead
if which gsed &> /dev/null; then
  sed='gsed'
fi

for shp in $(find "$input" -name '*.shp'); do
  input_shp_name=$(basename "$shp" .shp)
  out_geojson="${outdir}/${input_shp_name}.tmp_ndgeojson"
  s_srs_args=""
  if [[ ! -f "${input}/${input_shp_name}.prj" ]]; then
    s_srs_args="-s_srs EPSG:2446 "
  fi
  encoding_args=""
  if [[ ! -f "${input}/${input_shp_name}.cpg" ]]; then
    encoding_args="-oo ENCODING=CP932 "
  fi
  ogr2ogr $s_srs_args -t_srs EPSG:4326 -f GeoJSONSeq "${out_geojson}" $encoding_args "${shp}"

  name=$(echo "$input_shp_name" | $sed -r 's/\(.*?\)//g')
  name_subclass="$input_shp_name"
  out_geojson2="${outdir}/${name}.ndgeojson"
  jq -cr --arg 'class' "$name" --arg 'subclass' "$name_subclass" -f "$SCRIPT_DIR/convert_script.jq" "$out_geojson" >> "$out_geojson2"

  rm "$out_geojson"
done

for geojson in $(find "${outdir}" -name '*.ndgeojson'); do
  name=$(basename "$geojson" .ndgeojson)
  # ignore any errors because some files don't have any features
  tippecanoe \
    -Z0 -z14 \
    --read-parallel \
    --drop-densest-as-needed \
    --maximum-tile-bytes=1000000 \
    --maximum-tile-features=300000 \
    --force \
    --tile-stats-values-limit=0 \
    --layer="${name}" \
    --output="${outdir}"/"${name}".mbtiles \
    "$geojson" || true
done

tile-join \
  --force \
  --overzoom \
  --no-tile-size-limit \
  --tile-stats-values-limit=0 \
  -o ./smartcity_shape.mbtiles \
  "${outdir}"/*.mbtiles

rm -r "$outdir"