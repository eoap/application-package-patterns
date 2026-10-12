"""Select a processing runtime for acceptance without rewriting shared staging."""

from pathlib import Path

import yaml

RUNNER_IMAGE = "ghcr.io/eoap/application-package-patterns/runner"


def _replace(value: object, image: str) -> int:
    count = 0
    if isinstance(value, dict):
        pull = value.get("dockerPull")
        if isinstance(pull, str) and pull.startswith((RUNNER_IMAGE + ":", RUNNER_IMAGE + "@")):
            value["dockerPull"] = image
            count += 1
        for child in value.values():
            count += _replace(child, image)
    elif isinstance(value, list):
        for child in value:
            count += _replace(child, image)
    return count


def select_processing_image(path: Path, image: str) -> int:
    """Override this course's runner only; retain Mastering images and imports."""
    if not image.strip():
        raise ValueError("Processing image must not be empty")
    document = yaml.safe_load(path.read_text())
    count = _replace(document, image)
    if not count:
        raise ValueError("Workflow does not reference this course's processing image")
    path.write_text(yaml.safe_dump(document, sort_keys=False))
    return count


def main() -> None:
    """Select the accepted runtime in release assets without rebuilding it."""
    import argparse

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image", required=True)
    parser.add_argument("--directory", type=Path, required=True)
    args = parser.parse_args()
    for path in args.directory.rglob("*.cwl"):
        if RUNNER_IMAGE in path.read_text():
            select_processing_image(path, args.image)
            print(f"Selected accepted processing runtime in {path}")


if __name__ == "__main__":
    main()
