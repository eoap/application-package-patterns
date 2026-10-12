"""Download a STAC Item using the public staging SDK and a scoped HTTP client."""

import asyncio
from pathlib import Path

import aiohttp
import click
import pystac
import stac_asset
from stac_asset.http_client import HttpClient


async def main(href: str, output_dir: str) -> pystac.Catalog:
    item = pystac.read_file(href)
    if not isinstance(item, pystac.Item):
        raise ValueError("Stage-in input must be a STAC Item")
    target = Path(output_dir).resolve() / item.id
    target.mkdir(parents=True, exist_ok=True)
    config = stac_asset.Config(http_client_timeout=60, http_max_attempts=3)
    connector = aiohttp.TCPConnector(force_close=True)
    async with aiohttp.ClientSession(
        connector=connector, timeout=aiohttp.ClientTimeout(total=60)
    ) as session:
        staged = await stac_asset.download_item(
            item=item,
            directory=target,
            config=config,
            clients=[HttpClient(session, assert_content_type=False)],
            max_concurrent_downloads=8,
            stream=True,
        )
    catalog = pystac.Catalog(
        id="catalog",
        description=f"Catalog with staged {staged.id}",
        title=f"Catalog with staged {staged.id}",
    )
    catalog.add_item(staged)
    catalog.normalize_hrefs(str(target))
    catalog.save(catalog_type=pystac.CatalogType.SELF_CONTAINED)
    return catalog


@click.command()
@click.argument("href")
@click.option(
    "--output-dir", default=".", show_default=True, help="Directory where the catalog will be saved"
)
def cli(href: str, output_dir: str) -> None:
    """Download a STAC Item and stage a self-contained catalog."""
    asyncio.run(main(href, output_dir))


if __name__ == "__main__":
    cli()
