cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:name: Stage-in STAC assets
s:description: Download the assets of a STAC item for local processing.
s:dateCreated: '2022-09-01'
s:license:
  s:name: Creative Commons Attribution-ShareAlike 4.0 International
  s:url: https://creativecommons.org/licenses/by-sa/4.0/
  s:identifier: CC-BY-SA-4.0
s:softwareHelp:
  s:name: Mastering Earth Observation Application Packaging with CWL
  s:url: https://eoap.github.io/mastering-app-package
s:publisher:
  s:name: EO Application Packaging
  s:identifier: https://github.com/eoap
s:author:
- s:givenName: Jane
  s:familyName: Doe
  s:email: jane.doe@acme.earth
  s:affiliation:
    s:name: ACME
- s:givenName: John
  s:familyName: Doe
  s:email: john.doe@acme.earth
  s:affiliation:
    s:name: ACME
s:softwareRequirements:
- container runtime
- cwl runner
s:softwareVersion: 2.0.0
class: CommandLineTool
id: stage-in
inputs:
  reference:
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    label: STAC item reference
    doc: URI of the STAC item whose assets are downloaded.
    inputBinding:
      prefix: --reference
      valueFrom: $(self.value)
outputs:
  staged:
    type: Directory
    outputBinding:
      glob: .
    label: Staged acquisition
    doc: Directory containing the staged STAC catalog, item, and downloaded assets.
baseCommand: stage-in
requirements:
  DockerRequirement:
    dockerPull: ghcr.io/eoap/mastering-app-package/stage-in@sha256:fd951bad323ff63cc2c0cd95b7b212c05831da0f746cea20d754c6c6fc19844d
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true
  EnvVarRequirement:
    envDef:
      PATH: /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  SchemaDefRequirement:
    types:
    - type: record
      name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      doc: Represents a valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
      fields:
      - name: value
        type: string
        doc: A valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
  ResourceRequirement:
    coresMin: 1
    ramMin: 1024
    coresMax: 1
    ramMax: 1024
label: Stage-in STAC assets
doc: Download the assets of a STAC item for local processing.
s:codeRepository: https://github.com/eoap/mastering-app-package
s:isBasedOn: https://raw.githubusercontent.com/eoap/mastering-app-package/2.0.0/cwl-cli/stage-in.cwl
