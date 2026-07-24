# stage-in-file

Stage a remote file from a URL into the local workspace.

## Installation

```console
pip install stage-in-file
```

## Usage

```console
stage-in-file "https://example.com/data.tif" placeholder --output-path staged
```

The command signs the URL with `planetary_computer`, downloads it, and writes the file locally.
