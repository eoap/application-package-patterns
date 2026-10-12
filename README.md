# Application package patterns based on data stage-in and stage-out behaviors commonly used in EO workflows

Application packages expose several patterns in terms of data access and result publishing.

This repository contains CWL descriptions implementing these patterns to verification and validation activities

The patterns are:

## 1. one input/one output

The CWL includes: 
- one input parameter of type `Directory`
- one output parameter of type `Directory`

This scenario typically takes one input, applies an algorithm and produces a result

Implementation: delineate water bodies using NDWI and Otsu automatic threshold taking as input a Landsat-9 acquisition

## 2. two inputs/one output

The CWL includes: 
- two input parameters of type `Directory`
- one output parameter of type `Directory`

This scenario typically takes as input one pre-event acquisition, one post-even acquisition, applies an algorithm and produces a result

Implementation: delineate water bodies using NDWI and Otsu automatic threshold taking as input Landsat-9 acquisitions

## 3. scatter on inputs/one output

The CWL includes: 
- scatter on an input parameter of type `Directory[]`
- one output parameter of type `Directory`

This scenario typically takes as input a stack of acquisitions, applies an aggregation algorithm and produces a result

Implementation: process the NDVI taking as input a stack of Landsat-9 acquisitions producing a STAC Catalog with n STAC Items

```json
{
    "water_bodies": [
        {
            "value": "s3://results/pattern-3-9451lj/catalog.json",
            "type": "https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI"
        },
        {
            "value": "s3://results/pattern-3-ezt7al/catalog.json",
            "type": "https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI"
        }
    ]
}
```

## 4. one input/two outputs

The CWL includes: 
- one input parameter of type `Directory`
- two output parameters of type `Directory`

This scenario takes as input an acquisition, applies two algorithms and generates two outputs.

Implementation: process the NDVI and NDWI taking as input a Landsat-9 acquisition. The output include two STAC Catalogs, each with a single STAC Item

## 5. one input/scatter on outputs

The CWL includes: 
- one input parameter of type `Directory`
- scatter on an output parameter of type `Directory[]`

This scenario takes as input an acquisition, applies an algorithm and generates several outputs

Implementation: process the NDVI and NDWI taking as input a Landsat-9 acquisition and generating a stack of STAC Catalogs

## 6. one input, no output

The CWL includes: 
- one input parameter of type `Directory`
- there are no output parameters of type `Directory`

This corner-case scenario takes as input an acquisition, applies an algorithm and generates an output that is not a STAC Catalog

Implementation: derive the NDVI mean taking as input a Landsat-9 acquisition

Output:

```json
{
    "mean": 0.07260978
}
```

## 7. optional inputs, one output

The CWL includes: 
- one optional input parameter of type `Directory?`
- one output parameter of type `Directory`

This scenario may take as input an acquisition, an optional input, applies an algorithm and generates an output

Implementation: process the NDVI taking as input Landsat-9 acquisitions

## 8. one input, optional output

The CWL includes: 
- one input parameter of type `Directory`
- one output parameter of type `Directory?`

This scenario takes as input an acquisition, applies an algorithm and may or may not generate and output 

Implementation: process the NDVI taking as input a Landsat-9 acquisition with a parameter to create or not the output

## 9. one input, optional outputs

The CWL includes: 
- one input parameter of type `Directory`
- output parameter of type `Directory[]?`

This scenario takes as input an acquisition, applies an algorithm and may or may not generate outputs 

## 10. multiple inputs, multiple outputs

The CWL includes: 
- input parameter of type `Directory[]`
- output parameter of type `Directory[]`

This scenario takes as input an array of acquisition, applies an algorithm to each of them. 
## Typed CWL development

The feature checkout uses CWL v1.2 with embedded URI, bounding box, CRS,
spectral band and vegetation index definitions. Existing shared OGC and
GeoJSON schemas remain explicit imports. Metadata and port documentation are
validated by `python scripts/cwl-docs.py --validate --output /tmp/cwl-docs`.

The lessons are Markdown pages backed by twelve executable CWL examples. `eoap-cwlwrap` composes each example with the mastering stage-in/out commands; wrapper-introduced URI definitions are embedded in the resulting standalone document. No CWL packing step is used.

Install and validate the release environment:

```bash
uv venv --python 3.12 .venv
uv pip sync --python .venv/bin/python --require-hashes requirements-notebooks.txt
source .venv/bin/activate
task test:contracts
task wrap
```

Run all twelve patterns and four optional-input/output cases against real Landsat and DEM data using the `application-package-patterns` module in [dev-platform-eoap](https://github.com/eoap/dev-platform-eoap). Its `task labs` uses Calrissian on Kubernetes and the deployed SeaweedFS S3 endpoint. For a local Podman runner, configure `PATTERNS_S3_ENDPOINT`, prepare the bucket with `python scripts/prepare-s3.py`, then run `python scripts/run-acceptance.py --runner cwltool`.

The acceptance runner verifies published STAC links, readable raster assets, coordinate reference systems and intersection with the requested area. Pattern 6 returns a scalar normalized-index mean; its acceptance check verifies a finite value within [-1, 1]. Evidence includes execution logs, outputs and scientific checks for each case.

The staging provenance and immutable GHCR image references are recorded in `mastering-staging.lock.json`. Deployment uses GitHub resources and published containers; it requires no sibling host checkout.

## Locked processing model preparation

The course, runner and legacy staging helper use Python 3.12, Hatchling wheels
and hash-locked Hatch environments. Run `hatch run dev:check` and
`hatch run test:test` in each package. The runner uses a two-stage Rocky Linux
10.1 image, installs its accepted lock and wheel, and runs as UID/GID 2000.

The course environment installs its runner editable after the lock. The legacy
`stage-in` SDK helper has its own environment because its S3 client dependencies
conflict with the course environment; wrapped workflows continue to use the
published Mastering stage-in/out artifacts.

Signed vegetation-index outputs remain float32; binary zero is valid land and
is not nodata. Synthetic unit fixtures check these properties; release
acceptance must still run all sixteen real EO cases with the new runner image.
A successful package/image build alone is not release readiness.
