from pathlib import Path

import click
import planetary_computer
import requests


def stage_in_file(reference: str, another_input: str, output_path: str = "staged") -> Path:
    """Download a remote file to the requested local path."""
    signed_url = planetary_computer.sign(reference)
    destination = Path(output_path)

    response = requests.get(signed_url, stream=True)
    response.raise_for_status()

    with destination.open("wb") as file_obj:
        for chunk in response.iter_content(chunk_size=8192):
            if chunk:
                file_obj.write(chunk)

    _ = another_input
    return destination


@click.command()
@click.argument("reference")
@click.argument("another_input")
@click.option(
    "--output-path",
    default="staged",
    show_default=True,
    help="Path where the downloaded file will be written.",
)
def cli(reference: str, another_input: str, output_path: str):
    """Sign a URL with planetary-computer and download it locally."""
    destination = stage_in_file(reference, another_input, output_path)
    click.echo(f"Downloaded to {destination}")


if __name__ == "__main__":
    cli()
