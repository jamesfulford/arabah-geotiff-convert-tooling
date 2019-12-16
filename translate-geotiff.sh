#!/bin/bash

for l in ./lists/*.vrt; do
    echo $l
  gdal_translate -of "GTiff" "$l" "$l-tmp.tif"

  # Cut to shape
  gdalwarp \
    -of GTiff \
    -cutline ./shapes/biblical-arabah.shp \
    -cl biblical-arabah \
    -crop_to_cutline \
    "$l-tmp.tif" \
    "$l.biblical.tiff"
  gdalwarp \
    -of GTiff \
    -cutline ./shapes/modern-arabah.shp \
    -cl modern-arabah \
    -crop_to_cutline \
    "$l-tmp.tif" \
    "$l.modern.tiff"
done
