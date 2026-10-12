cwlVersion: v1.2
class: CommandLineTool
id: my-asthonishing-stage-in-file
inputs:
  reference:
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    doc: An URL to stage
    label: Reference URL
outputs:
  staged:
    type: File
    outputBinding:
      glob: staged
    label: staged
    doc: staged.
baseCommand:
- python
- stage.py
arguments:
- $( inputs.reference.value )
requirements:
  NetworkAccess:
    networkAccess: true
  SchemaDefRequirement:
    types:
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
  DockerRequirement:
    dockerPull: ghcr.io/eoap/mastering-app-package/stage-in@sha256:56623b24570fe8b28042cbe494c6da10cb4c758c28b303136d7dae1982b808f6
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
    - entryname: stage.py
      entry: 'import asyncio

        import sys

        from stac_asset import Config, download_file


        asyncio.run(download_file(sys.argv[1], "staged", config=Config(http_client_timeout=300,
        http_max_attempts=3)))

        print("Downloaded to staged")

        '
  EnvVarRequirement:
    envDef:
      PATH: /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  ResourceRequirement:
    coresMin: 1
    ramMin: 1024
$namespaces:
  s: https://schema.org/
s:softwareVersion: 2.0.0
s:codeRepository: https://github.com/eoap/application-package-patterns
s:license: https://spdx.org/licenses/MIT.html
s:author:
- class: s:Person
  s:name: Fabrice Brito
  s:email: fabrice.brito@terradue.com
label: Stage in file
doc: "Stage a real remote file using the mastering container\u2019s stac-asset transfer\
  \ library and Planetary Computer signing."
