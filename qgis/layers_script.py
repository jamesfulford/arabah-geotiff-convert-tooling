"""
Builds diffs
"""
from qgis.analysis import QgsRasterCalculatorEntry, QgsRasterCalculator
from qgis.core import QgsProject
import os


all_layers = [tree_layer.layer() for tree_layer in QgsProject.instance().layerTreeRoot().findLayers()]
all_ndvi_layers = sorted(list(filter(lambda l: "ndvi" in l.name(), all_layers)), key=lambda l: l.name())
output_directory = "/Users/jamesfulford/Desktop/Harvard Remote Sensing/arabah-project/diffs"
try:
    os.mkdir(output_directory)
except OSError:
    pass


def buildCalculatorEntry(layer):
    raster = QgsRasterCalculatorEntry()
    raster.ref = "{}@1".format(layer.name())
    raster.raster = layer
    raster.bandNumber = 1
    return raster


def calculate_diff(from_layer, to_layer):
    from_raster = buildCalculatorEntry(from_layer)
    to_raster = buildCalculatorEntry(to_layer)
    output_path = "{output_directory}/{from_name}-{to_name}.tiff".format(
        output_directory=output_directory,
        from_name=from_layer.name(),
        to_name=to_layer.name()
    )
    print(output_path)
    calc = QgsRasterCalculator(
        '{to_name}@1 - {from_name}@1'.format(
            from_name=from_layer.name(),
            to_name=to_layer.name()
        ),
        output_path,
        'GTiff',
        to_layer.extent(),
        to_layer.width(),
        to_layer.height(),
        [from_raster, to_raster]
    )
    calc.processCalculation()


for shape in ["biblical", "modern"]:
    ndvi_layers = list(filter(lambda l: shape in l.name(), all_ndvi_layers))
    print(ndvi_layers)
    for to_index in range(1, len(ndvi_layers)):
        from_index = to_index - 1
        from_layer = ndvi_layers[from_index]
        to_layer = ndvi_layers[to_index]
        calculate_diff(from_layer, to_layer)
    calculate_diff(ndvi_layers[0], ndvi_layers[-1])
