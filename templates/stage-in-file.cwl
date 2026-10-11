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
    - type: record
      name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      doc: Represents a valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
      fields:
      - name: value
        type: string
        doc: A valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
  DockerRequirement:
    dockerPull: ghcr.io/eoap/mastering-app-package/stage-in@sha256:fd951bad323ff63cc2c0cd95b7b212c05831da0f746cea20d754c6c6fc19844d
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
    - entryname: stage.py
      entry: "import sys\nimport requests\nimport planetary_computer\n\nhref = sys.argv[1]\n\
        \nsigned_url = planetary_computer.sign(href)\noutput_path = \"staged\"\n\n\
        response = requests.get(signed_url, stream=True, timeout=60)\nresponse.raise_for_status()\
        \  # Raise an error for bad status codes\n\nwith open(output_path, \"wb\"\
        ) as f:\n    for chunk in response.iter_content(chunk_size=8192):\n      \
        \  f.write(chunk)\n\nprint(f\"Downloaded to {output_path}\")\n\n"
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
doc: Stage in file for the STAC EOAP training module.
