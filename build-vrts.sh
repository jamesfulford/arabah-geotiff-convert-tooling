#!/bin/bash

for l in ./lists/*.txt; do
    echo $l
  gdalbuildvrt -input_file_list "$l" "$l.vrt"
done
