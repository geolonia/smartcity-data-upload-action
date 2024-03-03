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

createdMbtilesArchives=0

undefined_crs_setting=${SHAPEFILE_UNDEFINED_CRS_SETTING:-"EPSG:2446"}
for shp in $(find "$input" -name '*.shp'); do
  input_shp_name=$(basename "$shp" .shp)
  out_geojson="${outdir}/${input_shp_name}.tmp_ndgeojson"
  s_srs_args=""
  if [[ ! -f "${input}/${input_shp_name}.prj" ]]; then
    # TODO: 自治体によってデフォルトのEPSGが異なるので、自治体コードからマッピングすると優しいかも。
    s_srs_args="-s_srs ${undefined_crs_setting} "
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
  set +e
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
    "$geojson"
  if [[ $? -eq 0 ]]; then
    createdMbtilesArchives=$((createdMbtilesArchives+1))
  fi
  set -e
done

echo "We created $createdMbtilesArchives mbtiles archives."

# If there are no mbtiles archives to process, tile-join will return an error.
if [[ $createdMbtilesArchives -gt 0 ]]; then
  tile-join \
    --force \
    --overzoom \
    --no-tile-size-limit \
    --tile-stats-values-limit=0 \
    -o ./smartcity_shape.mbtiles \
    "${outdir}"/*.mbtiles
fi

rm -r "$outdir"
