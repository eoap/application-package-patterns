"""Synthetic unit fixtures; real EO acceptance runs separately."""

from datetime import UTC, datetime

import numpy as np
import pystac
import rasterio
from click.testing import CliRunner
from rasterio.transform import from_origin

from runner.pattern_1 import pattern_1
from runner.pattern_5 import pattern_5


def test_ndvi_preserves_signed_fractional_pixels(tmp_path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    bands = {
        "red": np.array([[3, 1], [1, 3]], dtype="uint16"),
        "nir08": np.array([[1, 3], [3, 1]], dtype="uint16"),
        "green": np.array([[2, 2], [2, 2]], dtype="uint16"),
    }
    item = pystac.Item(
        "unit-fixture",
        {"type": "Polygon", "coordinates": [[[0, 0], [2, 0], [2, 2], [0, 2], [0, 0]]]},
        [0, 0, 2, 2],
        datetime(2024, 1, 1, tzinfo=UTC),
        {},
    )
    for name, pixels in bands.items():
        path = tmp_path / f"{name}.tif"
        with rasterio.open(
            path,
            "w",
            driver="GTiff",
            width=2,
            height=2,
            count=1,
            dtype="uint16",
            crs="EPSG:4326",
            transform=from_origin(0, 2, 1, 1),
        ) as raster:
            raster.write(pixels, 1)
        item.add_asset(
            name,
            pystac.Asset(
                str(path),
                roles=["data"],
                extra_fields={"eo:bands": [{"name": name, "common_name": name}]},
            ),
        )
    item.set_self_href(str(tmp_path / "item.json"))
    item.save_object()
    result = CliRunner().invoke(
        pattern_5,
        [
            "--input-item",
            str(tmp_path / "item.json"),
            "--aoi",
            "0,0,2,2",
            "--epsg",
            "EPSG:4326",
            "--vegetation-index",
            "ndvi",
        ],
    )
    assert result.exit_code == 0, result.exception
    with rasterio.open(tmp_path / "ndvi" / "ndvi.tif") as raster:
        assert raster.dtypes == ("float32",)
        assert np.isnan(raster.nodata)
        np.testing.assert_array_equal(raster.read(1), [[-0.5, 0.5], [0.5, -0.5]])


def test_missing_band_reports_contract_error(tmp_path):
    item = pystac.Item("unit-fixture", None, None, datetime(2024, 1, 1, tzinfo=UTC), {})
    item.set_self_href(str(tmp_path / "item.json"))
    item.save_object()
    result = CliRunner().invoke(
        pattern_1,
        [
            "--input-item",
            str(tmp_path / "item.json"),
            "--aoi",
            "0,0,2,2",
            "--epsg",
            "EPSG:4326",
            "--band",
            "green",
        ],
    )
    assert isinstance(result.exception, ValueError)
    assert "not found" in str(result.exception)
