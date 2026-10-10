# Embedded URI schema derived from eoap/schemas (Copyright 2025 Terradue, Apache-2.0).
cwlVersion: v1.2
class: CommandLineTool
id: my-asthonishing-stage-in-directory
inputs:
  reference:
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    doc: A STAC Item to stage
    label: STAC Item URL
  another_input:
    type: string
    default: ''
    label: Additional example input
    doc: Optional parameter used to illustrate wrapper parameter propagation.
outputs:
  staged:
    type: Directory
    outputBinding:
      glob: .
    label: staged
    doc: staged.
baseCommand:
- python
- stage.py
arguments:
- $( inputs.reference.value )
- $( inputs.another_input )
requirements:
  NetworkAccess:
    networkAccess: true
  SchemaDefRequirement:
    types:
    - type: record
      name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      doc: Represents a valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
      fields:
      - name: value
        type: string
        doc: A valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
  DockerRequirement:
    dockerPull: ghcr.io/eoap/mastering-app-package/stage:1.0.0
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
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
$namespaces:
  s: https://schema.org/
s:softwareVersion: 0.0.1
s:codeRepository: https://github.com/eoap/application-package-patterns
s:license: https://spdx.org/licenses/MIT.html
s:author:
- class: s:Person
  s:name: Fabrice Brito
  s:email: fabrice.brito@terradue.com
label: Stage in
doc: Stage in for the STAC EOAP training module.
