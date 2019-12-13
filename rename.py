
import os


def rename(s):
    return s.replace("_hdf_file_list", "").replace(".txt.vrt", "")


modern_path = "./tiffs/modern/"
modern = os.listdir(modern_path)
for tiff in modern:
    os.rename(modern_path + tiff, modern_path + rename(tiff))
