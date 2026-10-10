# Embedded URI schema derived from eoap/schemas (Copyright 2025 Terradue, Apache-2.0).
cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.0.0
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
      coresMax: 1
      ramMax: 256
    DockerRequirement:
      dockerPull: ghcr.io/eoap/application-package-patterns/runner@sha256:db75818d12e3ea05b583ff53e32cd291fc3d40a62ae8cb53d51573c56813f1b6
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
s:license: https://spdx.org/licenses/MIT.html
s:author:
- class: s:Person
  s:name: Fabrice Brito
  s:email: fabrice.brito@terradue.com
