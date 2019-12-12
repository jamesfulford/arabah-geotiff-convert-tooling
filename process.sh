#!/bin/sh

directory=$1
mkdir "$directory"

# For each year, make a list of relevant HDF files
rm -rf lists
mkdir lists
for i in {2000..2019}; do
  file_list="./lists/${i}_hdf_file_list"
  rm -f "$file_list"
  for hdf_file in ./$directory/*$i*$i*.hdf; do
    echo 'HDF4_EOS:EOS_GRID:"'${hdf_file}'":MODIS_Grid_16DAY_1km_VI:"1 km 16 days NDVI"' >> "$file_list.ndvi.txt"
    # Other option:
    # echo 'HDF4_EOS:EOS_GRID:"'${hdf_file}'":MODIS_Grid_16DAY_1km_VI:"1 km 16 days EVI"' >> "$file_list.evi.txt"
  done
done

# For each year's list, make a VRT file
docker run -v"$PWD:/working-directory" -w /working-directory osgeo/gdal:latest "./build-vrts.sh"

# For each year's VRT, make a geotiff
docker run -v"$PWD:/working-directory" -w /working-directory osgeo/gdal:latest "./translate-geotiff.sh"

rm -rf "tiffs/$directory"
mkdir -p "tiffs/$directory"
mv ./lists/*.tiff "tiffs/$directory"
