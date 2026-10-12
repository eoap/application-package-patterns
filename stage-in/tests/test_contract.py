"""SDK contract rejection is independent of network or credentials."""

import asyncio
from pathlib import Path

import pystac
import pytest

from stage_in.app import main


def test_collection_rejected_before_network(tmp_path: Path) -> None:
    document = pystac.Catalog("unit-fixture", "Synthetic invalid stage-in input")
    path = tmp_path / "catalog.json"
    document.set_self_href(str(path))
    document.save_object()
    with pytest.raises(ValueError, match="must be a STAC Item"):
        asyncio.run(main(str(path), str(tmp_path / "output")))
    assert not (tmp_path / "output").exists()
