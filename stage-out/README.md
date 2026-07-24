# stage-out

Stage a local STAC catalog out to S3-compatible object storage.

## Installation

```console
pip install stage-out
```

## Usage

```console
stage-out /path/to/catalog my-bucket my-prefix \
  --aws-access-key-id ... \
  --aws-secret-access-key ... \
  --region-name ... \
  --endpoint-url ...
```

The command prints the staged catalog URI to stdout.
