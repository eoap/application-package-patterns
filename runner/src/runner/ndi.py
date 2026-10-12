import os
import shutil

import click
import pystac
import rasterio
import rio_stac
from loguru import logger

from runner.functions import get_collection, get_item, normalized_difference


@click.command(
    short_help="Nomalized Difference Index CLI",
    help="Calculates the Normalized Difference Index (NDI) for two input bands.",
)
@click.option(
    "--item-1",
    "item_1",
    help="Input item 1",
    required=True,
)
@click.option(
    "--item-2",
    "item_2",
    help="Input item 2",
    required=True,
)
@click.option("--item", "ls9_item", help="Landsat STAC Item", required=True)
@click.option(
    "--collection",
    "collection_url",
    help="STAC collection",
    required=False,
)
def ndi_cli(item_1: str, item_2: str, ls9_item: str, collection_url: str | None) -> None:

    collection = get_collection(collection_url)

    # read STAC Catalog
    item_1_stac = get_item(item_1)
    item_2_stac = get_item(item_2)

    ls9_item_stac = get_item(ls9_item)

    # get assets
    asset_1: pystac.Asset = item_1_stac.assets["data"]
    asset_2: pystac.Asset = item_2_stac.assets["data"]

    # read data
    with rasterio.open(asset_1.get_absolute_href()) as src1:
        data1 = src1.read(1)
        out_meta = src1.meta.copy()

    with rasterio.open(asset_2.get_absolute_href()) as src2:
        data2 = src2.read(1)

    # calculate normalized difference
    ndi_data = normalized_difference(data1, data2)

    ndi = "ndi.tif"

    out_meta.update(
        {
            "dtype": "float32",
            "driver": "COG",
            "tiled": True,
            "compress": "lzw",
            "blockxsize": 256,
            "blockysize": 256,
        }
    )

    with rasterio.open(ndi, "w", **out_meta) as dst_dataset:
        logger.info(f"Write {ndi}")
        dst_dataset.write(ndi_data, indexes=1)

    logger.info("Creating a STAC Catalog")
    cat = pystac.Catalog(id="catalog", description=f"Normalized difference from {ls9_item_stac.id}")

    output_item_id = f"ndi-{ls9_item_stac.id}".lower()

    os.makedirs(output_item_id, exist_ok=True)
    shutil.copy(ndi, output_item_id)

    out_item = rio_stac.stac.create_stac_item(
        source=ndi,
        input_datetime=ls9_item_stac.datetime,
        id=output_item_id,
        asset_roles=["data", "visual"],
        asset_href=os.path.basename(ndi),
        asset_name="data",
        with_proj=True,
        with_raster=True,
    )

    out_item.properties["renders"] = {
        "ndwi": {
            "title": "Normalized Difference Water Index",
            "assets": ["data"],
            "nodata": "0",
            "resampling": "nearest",
            "rescale": [[-1, 1]],
            "colormap_name": "blues_r",
        }
    }

    if collection:
        logger.info(f"Adding collection {collection.id} to the output item")
        out_item.collection_id = collection.id

    os.remove(ndi)
    cat.add_items([out_item])

    cat.normalize_and_save(root_href="./", catalog_type=pystac.CatalogType.SELF_CONTAINED)

    logger.info("Done!")
