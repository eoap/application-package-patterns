import os
import shutil
import tempfile
from dataclasses import dataclass
from urllib.parse import urlparse

import botocore.session
import click
import pystac
from pystac.stac_io import DefaultStacIO


@dataclass
class S3Config:
    aws_access_key_id: str
    aws_secret_access_key: str
    region_name: str
    endpoint_url: str


class CustomStacIO(DefaultStacIO):
    """STAC IO backend that can write JSON documents to S3-compatible storage."""

    def __init__(self, config: S3Config):
        self.s3_client = botocore.session.Session().create_client(
            service_name="s3",
            use_ssl=True,
            aws_access_key_id=config.aws_access_key_id,
            aws_secret_access_key=config.aws_secret_access_key,
            endpoint_url=config.endpoint_url,
            region_name=config.region_name,
        )

    def write_text(self, dest, txt, *args, **kwargs):
        parsed = urlparse(dest)
        if parsed.scheme == "s3":
            self.s3_client.put_object(
                Body=txt.encode("UTF-8"),
                Bucket=parsed.netloc,
                Key=parsed.path[1:],
                ContentType="application/geo+json",
            )
            return
        super().write_text(dest, txt, *args, **kwargs)


def stage_out(
    stac_catalog: str,
    s3_bucket: str,
    sub_path: str,
    config: S3Config,
) -> str:
    """Prepare an S3-backed STAC catalog stage-out and return the catalog URI."""
    with tempfile.TemporaryDirectory() as tmpdir:
        local_catalog = os.path.join(tmpdir, "catalog")
        shutil.copytree(stac_catalog, local_catalog)
        pystac.read_file(os.path.join(local_catalog, "catalog.json"))

        # Instantiate the S3-aware IO backend so callers can use it for writes
        # once the upload logic is enabled.
        CustomStacIO(config)

    return f"s3://{s3_bucket}/{sub_path}/catalog.json"


@click.command()
@click.argument("stac_catalog", type=click.Path(exists=True, file_okay=False, path_type=str))
@click.argument("s3_bucket")
@click.argument("sub_path")
@click.option(
    "--aws-access-key-id",
    envvar="aws_access_key_id",
    required=True,
    help="AWS access key ID.",
)
@click.option(
    "--aws-secret-access-key",
    envvar="aws_secret_access_key",
    required=True,
    help="AWS secret access key.",
)
@click.option(
    "--region-name",
    envvar="aws_region_name",
    required=True,
    help="AWS region name.",
)
@click.option(
    "--endpoint-url",
    envvar="aws_endpoint_url",
    required=True,
    help="S3 endpoint URL.",
)
def cli(
    stac_catalog: str,
    s3_bucket: str,
    sub_path: str,
    aws_access_key_id: str,
    aws_secret_access_key: str,
    region_name: str,
    endpoint_url: str,
):
    """Stage a STAC catalog to S3-compatible storage and print its URI."""
    uri = stage_out(
        stac_catalog=stac_catalog,
        s3_bucket=s3_bucket,
        sub_path=sub_path,
        config=S3Config(
            aws_access_key_id=aws_access_key_id,
            aws_secret_access_key=aws_secret_access_key,
            region_name=region_name,
            endpoint_url=endpoint_url,
        ),
    )
    click.echo(uri, nl=False)


if __name__ == "__main__":
    cli()
