cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 2.0.0
$graph:
- id: test-primitives
  class: Workflow
  label: Echo All CWL Primitive Types
  doc: This workflow demonstrates usage of all CWL primitive types. It runs the `echo-tool`
    with default values and captures the output in a file.
  requirements:
    InlineJavascriptRequirement: {}
    SchemaDefRequirement:
      types:
      - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
        type: record
        fields:
        - name: value
          type: string
      - name: '#BBox'
        type: record
        fields:
        - name: bbox
          type:
            type: array
            items: double
        - name: crs
          type: string
      - name: '#SpectralBand'
        type: enum
        symbols:
        - red
        - green
        - blue
        - nir
        - nir08
        - swir16
        - swir22
      - name: '#CRS'
        type: enum
        symbols:
        - '4326'
        - '3857'
        - '32610'
        - '32611'
        - native
      - name: '#VegetationIndex'
        type: enum
        symbols:
        - ndvi
        - ndwi
        - none
  inputs:
  - id: null_input
    type:
    - 'null'
    - string
    label: Nullable Input
    doc: A nullable input that can be null or a string
    default: null
  - id: boolean_input
    type: boolean
    label: Boolean Input
    doc: A boolean value
    default: true
  - id: int_input
    type: int
    label: Integer Input
    doc: An integer value
    default: 42
  - id: long_input
    type: long
    label: Long Input
    doc: A long integer value
    default: 1234567890123
  - id: float_input
    type: float
    label: Float Input
    doc: A floating-point number
    default: 3.14
  - id: double_input
    type: double
    label: Double Input
    doc: A double-precision float
    default: 2.7182818284
  - id: string_input
    type: string
    label: String Input
    doc: A string input
    default: Hello, CWL!
  outputs:
  - id: echoed_values
    type: string
    outputSource:
    - echo_step/echoed
    label: Echoed Values
    doc: The string containing echoed primitive values
  steps:
    echo_step:
      run: '#clt'
      in: {}
      out:
      - echoed
- class: CommandLineTool
  label: Echo Primitive Types Tool
  doc: A tool that echoes all primitive CWL types null, boolean, int, long, float,
    double, and string. The values are written to a file called `echoed.txt`.
  id: clt
  requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef:
        PATH: /app/envs/runner/bin:/usr/bin
    ResourceRequirement:
      coresMin: 1
      ramMin: 2048
      coresMax: 1
      ramMax: 2048
    DockerRequirement:
      dockerPull: ghcr.io/eoap/application-package-patterns/runner@sha256:e9650bd0a6c5fc25ee5e52fcfa5cad8e77bb75582ce3a628ee43dfd5f3155ab0
    SchemaDefRequirement:
      types:
      - name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
        type: record
        fields:
        - name: value
          type: string
      - name: '#BBox'
        type: record
        fields:
        - name: bbox
          type:
            type: array
            items: double
        - name: crs
          type: string
      - name: '#SpectralBand'
        type: enum
        symbols:
        - red
        - green
        - blue
        - nir
        - nir08
        - swir16
        - swir22
      - name: '#CRS'
        type: enum
        symbols:
        - '4326'
        - '3857'
        - '32610'
        - '32611'
        - native
      - name: '#VegetationIndex'
        type: enum
        symbols:
        - ndvi
        - ndwi
        - none
  baseCommand:
  - echo
  arguments:
  - $(inputs.null_input)
  - $(inputs.boolean_input)
  - $(inputs.int_input)
  - $(inputs.long_input)
  - $(inputs.float_input)
  - $(inputs.double_input)
  - $(inputs.string_input)
  inputs:
    null_input:
      type:
      - 'null'
      - string
      inputBinding:
        position: 0
      doc: A nullable input (null or string)
      default: null
      label: null_input
    boolean_input:
      type: boolean
      inputBinding:
        position: 1
      doc: A boolean value
      default: true
      label: boolean_input
    int_input:
      type: int
      inputBinding:
        position: 2
      doc: An integer value
      default: 42
      label: int_input
    long_input:
      type: long
      inputBinding:
        position: 3
      doc: A long integer
      default: 1234567890123
      label: long_input
    float_input:
      type: float
      inputBinding:
        position: 4
      doc: A floating-point number
      default: 3.14
      label: float_input
    double_input:
      type: double
      inputBinding:
        position: 5
      doc: A double-precision float
      default: 2.7182818284
      label: double_input
    string_input:
      type: string
      inputBinding:
        position: 6
      doc: A string input
      default: Hello, CWL!
      label: string_input
  stdout: message
  outputs:
    echoed:
      outputBinding:
        glob: message
        loadContents: true
        outputEval: $(self[0].contents)
      type: string
      label: echoed
      doc: echoed.
s:codeRepository: https://github.com/eoap/application-package-patterns
s:license:
  '@type': s:CreativeWork
  s:identifier: Apache-2.0
s:author:
- '@type': s:Role
  s:roleName: Project Manager
  s:additionalType: http://purl.org/spar/datacite/ProjectManager
  s:author:
    '@type': s:Person
    s:givenName: Lois
    s:familyName: Lane
    s:email: lois.lane@dailyplanet.com
    s:identifier: https://orcid.org/0000-9999-0000-9999
    s:affiliation:
      '@type': s:Organization
      s:name: Daily Planet
      s:identifier: https://ror.org/0000cx000
- '@type': s:Role
  s:roleName: Researcher
  s:additionalType: http://purl.org/spar/datacite/Researcher
  s:author:
    '@type': s:Person
    s:givenName: Clark
    s:familyName: Kent
    s:email: clark.kent@dailyplanet.com
    s:identifier: https://orcid.org/0000-9999-0000-9999
    s:affiliation:
      '@type': s:Organization
      s:name: Daily Planet
      s:identifier: https://ror.org/0000cx000
s:name: Echo All CWL Primitive Types
s:description: This workflow demonstrates usage of all CWL primitive types. It runs
  the `echo-tool` with default values and captures the output in a file.
s:dateCreated: '2025-01-01'
s:keywords:
- CWL
- Workflow
- Earth Observation
s:operatingSystem:
- Linux
- macOS
s:softwareRequirements:
- https://cwltool.readthedocs.io/en/latest/
- https://www.python.org/
s:softwareHelp:
- '@type': s:CreativeWork
  s:name: User Manual
  s:url: tps://eoap.github.io/application-package-patterns/
s:publisher:
  '@type': s:Organization
  s:name: Make Earth Observation Great Again
  s:email: info@meoga.com
  s:identifier: https://ror.org/9999cx000
s:contributor:
- '@type': s:Person
  s:givenName: Lex
  s:familyName: Luthor
  s:email: lex.luthor@luthorcorp.com
  s:identifier: https://orcid.org/0000-9999-0000-9999
  s:affiliation:
    '@type': s:Organization
    s:name: Luthor Corp
    s:identifier: https://ror.org/0000cx000
