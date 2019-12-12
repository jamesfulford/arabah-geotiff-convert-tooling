#!/bin/bash

for l in ./lists/*.vrt; do
    echo $l
  gdal_translate -of "GTiff" "$l" "$l.tiff"
done
