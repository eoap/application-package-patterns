"""Shared SDK-based scientific operations for application package patterns."""

import os

import numpy as np
import pystac
import rasterio
from loguru import logger
from numpy.typing import NDArray
from pyproj import Transformer
from pystac.extensions.eo import AssetEOExtension
from rasterio.mask import mask
from shapely import box
from skimage.filters import threshold_otsu


def crop(
    asset: pystac.Asset, bbox: list[float], epsg: str
) -> tuple[NDArray[np.float32], dict[str, object]]:
    """_summary_

    Args:
        asset (_type_): _description_
        bbox (_type_): _description_
        epsg (_type_): _description_

    Returns:
        _type_: _description_
    """
    with rasterio.open(asset.get_absolute_href()) as src:
        transformer = Transformer.from_crs(epsg, src.crs, always_xy=True)

        minx, miny = transformer.transform(bbox[0], bbox[1])
        maxx, maxy = transformer.transform(bbox[2], bbox[3])

        transformed_bbox = box(minx, miny, maxx, maxy)

        logger.info(f"Crop {asset.get_absolute_href()}")

        out_image, out_transform = mask(src, [transformed_bbox], crop=True)
        out_meta: dict[str, object] = src.meta.copy()

        out_meta.update(
            {
                "height": out_image.shape[1],
                "width": out_image.shape[2],
                "transform": out_transform,
            }
        )

        cropped: NDArray[np.float32] = out_image.astype(np.float32)
        return cropped, out_meta


def threshold(data: NDArray[np.float32]) -> NDArray[np.bool_]:
    """Returns the Otsu threshold of a numpy array"""
    result: NDArray[np.bool_] = data > threshold_otsu(data[np.isfinite(data)])
    return result


def normalized_difference(
    array1: NDArray[np.float32], array2: NDArray[np.float32]
) -> NDArray[np.float32]:
    """Returns the normalized difference of two numpy arrays"""
    result: NDArray[np.float32] = (array1 - array2) / (array1 + array2)
    return result


def aoi2box(aoi: str) -> list[float]:
    """Converts an area of interest expressed as a bounding box to a list of floats"""
    return [float(c) for c in aoi.split(",")]


def get_asset(item: pystac.Item, common_name: str) -> pystac.Asset | None:
    """Returns the asset of a STAC Item defined with its common band name"""
    for _, asset in item.get_assets().items():
        if "data" not in asset.to_dict()["roles"]:
            continue

        eo_asset = AssetEOExtension(asset)
        if not eo_asset.bands:
            continue
        for b in eo_asset.bands:
            if b.common_name == common_name:
                return asset
    return None


def get_item(item_url: str) -> pystac.Item:
    item: pystac.STACObject | None
    if os.path.isdir(item_url):
        catalog = pystac.read_file(os.path.join(item_url, "catalog.json"))
        if not isinstance(catalog, pystac.Catalog):
            raise ValueError("Staged input must contain a STAC Catalog")
        item = next(iter(catalog.get_items()), None)
    else:
        item = pystac.read_file(item_url)
    if not isinstance(item, pystac.Item):
        raise ValueError("Input must identify a STAC Item")
    return item


def get_collection(href: str | None) -> pystac.Collection | None:
    if not href:
        return None
    document = pystac.read_file(href)
    if not isinstance(document, pystac.Collection):
        raise ValueError("Collection input must be a STAC Collection")
    return document
