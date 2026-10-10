cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.0.1
s:applicationCategory: Earth Observation application package
s:additionalProperty:
- '@type': s:PropertyValue
  s:name: application-type
  s:value: delineation
- '@type': s:PropertyValue
  s:name: domain
  s:value: hydrology
s:codeRepository: https://github.com/eoap/application-package-patterns
s:license: https://spdx.org/licenses/MIT.html
s:author:
- class: s:Person
  s:name: Fabrice Brito
  s:email: fabrice.brito@terradue.com
$graph:
- id: main
  class: Workflow
  label: Workflow pattern-2 orchestrator
  doc: This Workflow is used to orchestrate the Workflow pattern-2
  inputs:
  - id: aoi
    label: area of interest - pattern-2/aoi
    doc: area of interest as a bounding box - This parameter is derived from pattern-2/aoi
    default:
      bbox:
      - -118.985
      - 38.432
      - -118.183
      - 38.938
      crs: CRS84
    type: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox
  - id: epsg
    label: EPSG code - pattern-2/epsg
    doc: EPSG code - This parameter is derived from pattern-2/epsg
    default: '4326'
    type: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS
  - id: bands
    label: bands used for the NDWI - pattern-2/bands
    doc: bands used for the NDWI - This parameter is derived from pattern-2/bands
    default:
    - green
    - nir08
    type:
      name: _:3a76f667-3d84-4a8d-8c3e-0f60cce80eb6
      items: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand
      type: array
  - id: another_input
    label: Additional example input - my-asthonishing-stage-in-directory/another_input
    doc: Optional parameter used to illustrate wrapper parameter propagation. - This
      parameter is derived from my-asthonishing-stage-in-directory/another_input
    default: ''
    type: string
  - id: item_1
    label: Landsat-8/9 acquisition reference - pattern-2/item_1
    doc: Landsat-8/9 acquisition reference - This parameter is derived from pattern-2/item_1
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
  - id: item_2
    label: Landsat-8/9 acquisition reference - pattern-2/item_2
    doc: Landsat-8/9 acquisition reference - This parameter is derived from pattern-2/item_2
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
  - id: s3_bucket
    label: s3 bucket - my-super-stage-out/s3_bucket
    doc: s3 bucket. - This parameter is derived from my-super-stage-out/s3_bucket
    type: string
  - id: sub_path
    label: sub path - my-super-stage-out/sub_path
    doc: sub path. - This parameter is derived from my-super-stage-out/sub_path
    type: string
  - id: aws_access_key_id
    label: aws access key id - my-super-stage-out/aws_access_key_id
    doc: aws access key id. - This parameter is derived from my-super-stage-out/aws_access_key_id
    type: string
  - id: aws_secret_access_key
    label: aws secret access key - my-super-stage-out/aws_secret_access_key
    doc: aws secret access key. - This parameter is derived from my-super-stage-out/aws_secret_access_key
    type: string
  - id: region_name
    label: region name - my-super-stage-out/region_name
    doc: region name. - This parameter is derived from my-super-stage-out/region_name
    type: string
  - id: endpoint_url
    label: endpoint url - my-super-stage-out/endpoint_url
    doc: endpoint url. - This parameter is derived from my-super-stage-out/endpoint_url
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
  outputs:
  - id: water_bodies
    label: Water bodies detected
    doc: Water bodies detected based on the NDWI and otsu threshold
    outputSource: stage_out_0/s3_catalog_output
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
  requirements:
  - class: SubworkflowFeatureRequirement
  - class: SchemaDefRequirement
    types:
    - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      fields:
      - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI/value
        type: string
      type: record
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox
      fields:
      - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox/bbox
        type:
          name: _:dc75ad79-3a30-46ad-be2e-8ae40022c281
          items: double
          type: array
      - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox/crs
        type: string
      type: record
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand
      symbols:
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/red
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/green
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/blue
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/nir
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/nir08
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/swir16
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/swir22
      type: enum
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS
      symbols:
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/4326
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/3857
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/32610
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/32611
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/native
      type: enum
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex
      symbols:
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex/ndvi
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex/ndwi
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex/none
      type: enum
  steps:
  - id: directory_stage_in_0
    label: Stage-in 0
    doc: Stage-in Directory 0
    in:
    - id: reference
      source: item_1
    - id: another_input
      source: another_input
    out:
    - staged
    run: '#my-asthonishing-stage-in-directory'
  - id: directory_stage_in_1
    label: Stage-in 1
    doc: Stage-in Directory 1
    in:
    - id: reference
      source: item_2
    - id: another_input
      source: another_input
    out:
    - staged
    run: '#my-asthonishing-stage-in-directory'
  - id: app
    label: Water bodies detection based on NDWI and the otsu threshold
    doc: Water bodies detection based on NDWI and otsu threshold applied to a pair
      of Landsat-8/9 acquisitions
    in:
    - id: aoi
      source: aoi
    - id: epsg
      source: epsg
    - id: bands
      source: bands
    - id: item_1
      source: directory_stage_in_0/staged
    - id: item_2
      source: directory_stage_in_1/staged
    out:
    - water_bodies
    run: '#pattern-2'
  - id: stage_out_0
    label: Stage-out 0
    doc: Stage-out Directory 0
    in:
    - id: s3_bucket
      source: s3_bucket
    - id: sub_path
      source: sub_path
    - id: aws_access_key_id
      source: aws_access_key_id
    - id: aws_secret_access_key
      source: aws_secret_access_key
    - id: region_name
      source: region_name
    - id: endpoint_url
      source: endpoint_url
    - id: stac_catalog
      source: app/water_bodies
    out:
    - s3_catalog_output
    run: '#my-super-stage-out'
- id: pattern-2
  class: Workflow
  label: Water bodies detection based on NDWI and the otsu threshold
  doc: Water bodies detection based on NDWI and otsu threshold applied to a pair of
    Landsat-8/9 acquisitions
  inputs:
  - id: aoi
    label: area of interest
    doc: area of interest as a bounding box
    default:
      bbox:
      - -118.985
      - 38.432
      - -118.183
      - 38.938
      crs: CRS84
    type: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox
  - id: epsg
    label: EPSG code
    doc: EPSG code
    default: '4326'
    type: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS
  - id: bands
    label: bands used for the NDWI
    doc: bands used for the NDWI
    default:
    - green
    - nir08
    type:
      name: _:3a76f667-3d84-4a8d-8c3e-0f60cce80eb6
      items: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand
      type: array
  - id: item_1
    label: Landsat-8/9 acquisition reference
    doc: Landsat-8/9 acquisition reference
    type: Directory
  - id: item_2
    label: Landsat-8/9 acquisition reference
    doc: Landsat-8/9 acquisition reference
    type: Directory
  outputs:
  - id: water_bodies
    label: Water bodies detected
    doc: Water bodies detected based on the NDWI and otsu threshold
    outputSource:
    - step/stac-catalog
    type: Directory
  requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
    - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      fields:
      - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI/value
        type: string
      type: record
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox
      fields:
      - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox/bbox
        type:
          name: _:dc75ad79-3a30-46ad-be2e-8ae40022c281
          items: double
          type: array
      - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox/crs
        type: string
      type: record
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand
      symbols:
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/red
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/green
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/blue
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/nir
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/nir08
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/swir16
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/swir22
      type: enum
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS
      symbols:
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/4326
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/3857
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/32610
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/32611
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/native
      type: enum
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex
      symbols:
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex/ndvi
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex/ndwi
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex/none
      type: enum
  cwlVersion: v1.2
  steps:
  - id: step
    in:
    - id: item_1
      source: item_1
    - id: item_2
      source: item_2
    - id: aoi
      source: aoi
    - id: epsg
      source: epsg
    - id: band
      source: bands
    out:
    - stac-catalog
    run: '#clt'
- id: clt
  class: CommandLineTool
  label: clt
  doc: 'application-package-patterns: clt.'
  inputs:
  - id: item_1
    label: item_1
    doc: item 1.
    type: Directory
    inputBinding:
      prefix: --input-item-1
  - id: item_2
    label: item_2
    doc: item 2.
    type: Directory
    inputBinding:
      prefix: --input-item-2
  - id: aoi
    label: aoi
    doc: aoi.
    type: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox
    inputBinding:
      prefix: --aoi
      valueFrom: $(self.bbox.join(","))
  - id: epsg
    label: epsg
    doc: epsg.
    type: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS
    inputBinding:
      prefix: --epsg
      valueFrom: '$(self === "native" ? self : "EPSG:" + self)'
  - id: band
    label: band
    doc: band.
    type:
    - name: _:6f11658a-0aa0-4bc5-9da5-8138d9c79082
      items: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand
      type: array
      inputBinding:
        prefix: --band
  outputs:
  - id: stac-catalog
    label: stac-catalog
    doc: stac catalog.
    type: Directory
    outputBinding:
      glob: .
  requirements:
  - class: InlineJavascriptRequirement
  - class: EnvVarRequirement
    envDef:
    - envName: PATH
      envValue: $PATH:/app/envs/runner/bin
  - class: ResourceRequirement
    coresMax: 1
    ramMax: 512
  - class: SchemaDefRequirement
    types:
    - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      fields:
      - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI/value
        type: string
      type: record
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox
      fields:
      - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox/bbox
        type:
          name: _:48976591-d396-448d-ac87-b82d6b1630d1
          items: double
          type: array
      - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#BBox/crs
        type: string
      type: record
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand
      symbols:
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/red
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/green
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/blue
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/nir
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/nir08
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/swir16
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#SpectralBand/swir22
      type: enum
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS
      symbols:
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/4326
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/3857
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/32610
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/32611
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#CRS/native
      type: enum
    - name: file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex
      symbols:
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex/ndvi
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex/ndwi
      - file:///workspace/application-package-patterns/cwl-workflow/pattern-2.cwl#VegetationIndex/none
      type: enum
  hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/application-package-patterns/runner:0.2.0
  cwlVersion: v1.2
  baseCommand:
  - runner
  arguments:
  - pattern-2
- https://schema.org/softwareVersion: 0.0.1
  https://schema.org/codeRepository: https://github.com/eoap/application-package-patterns
  https://schema.org/license: https://spdx.org/licenses/MIT.html
  https://schema.org/author:
  - class: s:Person
    s:name: Fabrice Brito
    s:email: fabrice.brito@terradue.com
  id: my-asthonishing-stage-in-directory
  class: CommandLineTool
  label: Stage in
  doc: Stage in for the STAC EOAP training module.
  inputs:
  - id: reference
    label: STAC Item URL
    doc: A STAC Item to stage
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
  - id: another_input
    label: Additional example input
    doc: Optional parameter used to illustrate wrapper parameter propagation.
    default: ''
    type: string
  outputs:
  - id: staged
    label: staged
    doc: staged.
    type: Directory
    outputBinding:
      glob: .
  requirements:
  - class: NetworkAccess
    networkAccess: true
  - class: SchemaDefRequirement
    types:
    - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      fields:
      - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI/value
        doc: A valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
        type: string
      type: record
      doc: Represents a valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/mastering-app-package/stage:1.0.0
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
    - entryname: stage.py
      entry: "import pystac\nimport stac_asset\nimport asyncio\nimport aiohttp\nfrom\
        \ stac_asset.errors import DownloadError\nimport os\nimport sys\n\nconfig\
        \ = stac_asset.Config(warn=False, http_client_timeout=180, http_max_attempts=3,\
        \ fail_fast=False)\n\nasync def main(href: str):\n    \n    item = pystac.read_file(href)\n\
        \    \n    os.makedirs(item.id, exist_ok=True)\n    cwd = os.getcwd()\n  \
        \  \n    os.chdir(item.id)\n    source_item = item.clone()\n    for attempt\
        \ in range(3):\n        try:\n            item = await stac_asset.download_item(item=source_item.clone(),\
        \ directory=\".\", config=config)\n            break\n        except (aiohttp.ClientError,\
        \ asyncio.TimeoutError, DownloadError) as error:\n            if isinstance(error,\
        \ DownloadError) and not all(isinstance(child, (aiohttp.ClientError, asyncio.TimeoutError))\
        \ for child in error.exceptions):\n                raise\n            if attempt\
        \ == 2:\n                raise\n            print(f\"Incomplete remote transfer;\
        \ retrying staging attempt {attempt + 2}/3\", file=sys.stderr)\n         \
        \   await asyncio.sleep(2 ** (attempt + 1))\n    os.chdir(cwd)\n    \n   \
        \ cat = pystac.Catalog(\n        id=\"catalog\",\n        description=f\"\
        catalog with staged {item.id}\",\n        title=f\"catalog with staged {item.id}\"\
        ,\n    )\n    cat.add_item(item)\n    \n    cat.normalize_hrefs(\"./\")\n\
        \    cat.save(catalog_type=pystac.CatalogType.SELF_CONTAINED)\n\n    return\
        \ cat\n\nhref = sys.argv[1]\nempty_arg = sys.argv[2]\n\ncat = asyncio.run(main(href))"
  cwlVersion: v1.2
  baseCommand:
  - python
  - stage.py
  arguments:
  - $( inputs.reference.value )
  - $( inputs.another_input )
- https://schema.org/softwareVersion: 0.0.1
  https://schema.org/codeRepository: https://github.com/eoap/application-package-patterns
  https://schema.org/license: https://spdx.org/licenses/MIT.html
  https://schema.org/author:
  - class: s:Person
    s:name: Fabrice Brito
    s:email: fabrice.brito@terradue.com
  id: my-asthonishing-stage-in-file
  class: CommandLineTool
  label: Stage in file
  doc: Stage in file for the STAC EOAP training module.
  inputs:
  - id: reference
    label: Reference URL
    doc: An URL to stage
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
  - id: another_input
    label: Additional example input
    doc: Optional parameter used to illustrate wrapper parameter propagation.
    default: ''
    type: string
  outputs:
  - id: staged
    label: staged
    doc: staged.
    type: File
    outputBinding:
      glob: staged
  requirements:
  - class: NetworkAccess
    networkAccess: true
  - class: SchemaDefRequirement
    types:
    - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      fields:
      - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI/value
        doc: A valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
        type: string
      type: record
      doc: Represents a valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/application-package-patterns/vegetation-indexes:0.1.1
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
    - entryname: stage.py
      entry: "import sys\nimport requests\nimport planetary_computer\n\nhref = sys.argv[1]\n\
        \nsigned_url = planetary_computer.sign(href)\noutput_path = \"staged\"\n\n\
        response = requests.get(signed_url, stream=True, timeout=60)\nresponse.raise_for_status()\
        \  # Raise an error for bad status codes\n\nwith open(output_path, \"wb\"\
        ) as f:\n    for chunk in response.iter_content(chunk_size=8192):\n      \
        \  f.write(chunk)\n\nprint(f\"Downloaded to {output_path}\")\n\nempty_arg\
        \ = sys.argv[2]"
  cwlVersion: v1.2
  baseCommand:
  - python
  - stage.py
  arguments:
  - $( inputs.reference.value )
  - $( inputs.another_input )
- https://schema.org/softwareVersion: 0.0.1
  https://schema.org/codeRepository: https://github.com/eoap/application-package-patterns
  https://schema.org/license: https://spdx.org/licenses/MIT.html
  https://schema.org/author:
  - class: s:Person
    s:name: Fabrice Brito
    s:email: fabrice.brito@terradue.com
  id: my-super-stage-out
  class: CommandLineTool
  label: Stage out
  doc: Stage-out the results to S3
  inputs:
  - id: s3_bucket
    label: s3 bucket
    doc: s3 bucket.
    type: string
  - id: sub_path
    label: sub path
    doc: sub path.
    type: string
  - id: aws_access_key_id
    label: aws access key id
    doc: aws access key id.
    type: string
  - id: aws_secret_access_key
    label: aws secret access key
    doc: aws secret access key.
    type: string
  - id: region_name
    label: region name
    doc: region name.
    type: string
  - id: endpoint_url
    label: endpoint url
    doc: endpoint url.
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
  - id: stac_catalog
    label: STAC Catalog folder
    doc: The folder containing the STAC catalog to stage out
    type: Directory
  outputs:
  - id: s3_catalog_output
    label: s3 catalog output
    doc: s3 catalog output.
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    outputBinding:
      outputEval: '${ return {value: "s3://" + inputs.s3_bucket + "/" + inputs.sub_path
        + "/catalog.json"}; }'
  requirements:
  - class: NetworkAccess
    networkAccess: true
  - class: SchemaDefRequirement
    types:
    - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      fields:
      - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI/value
        doc: A valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
        type: string
      type: record
      doc: Represents a valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/mastering-app-package/stage:1.0.0
  - class: InlineJavascriptRequirement
  - class: EnvVarRequirement
    envDef:
    - envName: aws_access_key_id
      envValue: $( inputs.aws_access_key_id )
    - envName: aws_secret_access_key
      envValue: $( inputs.aws_secret_access_key )
    - envName: aws_region_name
      envValue: $( inputs.region_name )
    - envName: aws_endpoint_url
      envValue: $( inputs.endpoint_url.value )
  - class: ResourceRequirement
  - class: InitialWorkDirRequirement
    listing:
    - entryname: stage.py
      entry: "import os\nimport sys\nimport pystac\nimport botocore\nimport boto3\n\
        import shutil\nfrom pystac.stac_io import DefaultStacIO, StacIO\nfrom urllib.parse\
        \ import urlparse\n\ncat_url = sys.argv[1]\nbucket = sys.argv[2]\nsubfolder\
        \ = sys.argv[3]\n\naws_access_key_id = os.environ[\"aws_access_key_id\"]\n\
        aws_secret_access_key = os.environ[\"aws_secret_access_key\"]\nregion_name\
        \ = os.environ[\"aws_region_name\"]\nendpoint_url = os.environ[\"aws_endpoint_url\"\
        ]\n\nshutil.copytree(cat_url, \"/tmp/catalog\")\ncat = pystac.read_file(os.path.join(\"\
        /tmp/catalog\", \"catalog.json\"))\n\nclass CustomStacIO(DefaultStacIO):\n\
        \    \"\"\"Custom STAC IO class that uses boto3 to read from S3.\"\"\"\n\n\
        \    def __init__(self):\n        self.session = botocore.session.Session()\n\
        \        self.s3_client = self.session.create_client(\n            service_name=\"\
        s3\",\n            use_ssl=True,\n            aws_access_key_id=aws_access_key_id,\n\
        \            aws_secret_access_key=aws_secret_access_key,\n            endpoint_url=endpoint_url,\n\
        \            region_name=region_name,\n        )\n\n    def write_text(self,\
        \ dest, txt, *args, **kwargs):\n        parsed = urlparse(dest)\n        if\
        \ parsed.scheme == \"s3\":\n            self.s3_client.put_object(\n     \
        \           Body=txt.encode(\"UTF-8\"),\n                Bucket=parsed.netloc,\n\
        \                Key=parsed.path[1:],\n                ContentType=\"application/geo+json\"\
        ,\n            )\n        else:\n            super().write_text(dest, txt,\
        \ *args, **kwargs)\n\n\nclient = boto3.client(\n    \"s3\",\n    aws_access_key_id=aws_access_key_id,\n\
        \    aws_secret_access_key=aws_secret_access_key,\n    endpoint_url=endpoint_url,\n\
        \    region_name=region_name,\n)\n\nStacIO.set_default(CustomStacIO)\n\nfor\
        \ item in cat.get_items():\n    for key, asset in item.get_assets().items():\n\
        \        s3_path = os.path.normpath(\n            os.path.join(os.path.join(subfolder,\
        \ item.id, asset.href))\n        )\n        print(f\"upload {asset.href} to\
        \ s3://{bucket}/{s3_path}\",file=sys.stderr)\n        client.upload_file(\n\
        \            asset.get_absolute_href(),\n            bucket,\n           \
        \ s3_path,\n        )\n        asset.href = f\"s3://{bucket}/{s3_path}\"\n\
        \        item.add_asset(key, asset)\n\ncat.set_root(cat)\nfor item in cat.get_items():\n\
        \    item.set_root(cat)\ncat.normalize_hrefs(f\"s3://{bucket}/{subfolder}\"\
        )\n\nfor item in cat.get_items():\n    # upload item to S3\n    print(f\"\
        upload {item.id} to s3://{bucket}/{subfolder}\", file=sys.stderr)\n    pystac.write_file(item,\
        \ item.get_self_href())\n\n# upload catalog to S3\nprint(f\"upload catalog.json\
        \ to s3://{bucket}/{subfolder}\", file=sys.stderr)\npystac.write_file(cat,\
        \ cat.get_self_href())\n\nprint(f\"s3://{bucket}/{subfolder}/catalog.json\"\
        , end=\"\", file=sys.stdout)"
  cwlVersion: v1.2
  baseCommand:
  - python
  - stage.py
  arguments:
  - $( inputs.stac_catalog.path )
  - $( inputs.s3_bucket )
  - $( inputs.sub_path )
  stdout: catalog-uri.txt
