cwlVersion: v1.0
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf
$namespaces:
  s: https://schema.org/
  eoap: "http://oeap.github.io/schema"

s:name: Echo All CWL Primitive Types
s:description: This workflow demonstrates usage of all CWL primitive types. It runs the `echo-tool` with default values and captures the output in a file.
s:dateCreated: '2025-01-01'
s:license:
  '@type': s:CreativeWork
  s:identifier: Apache-2.0

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

s:softwareVersion: 1.0.0
s:softwareHelp:
- '@type': s:CreativeWork
  s:name: User Manual
  s:url: tps://eoap.github.io/application-package-patterns/

s:publisher:
  '@type': s:Organization
  s:name: Make Earth Observation Great Again
  s:email: info@meoga.com
  s:identifier: https://ror.org/9999cx000

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

$graph:
  - id: test-primitives
    class: Workflow
    label: Echo All CWL Primitive Types
    doc: This workflow demonstrates usage of all CWL primitive types. It runs the `echo-tool` with default values and captures the output in a file.
    requirements: []
    hints:
    - class: eoap:JSONSchemaHint
    inputs:
    - id: null_input
      type: ["null", "string"]
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
      default: "Hello, CWL!"

    outputs:
      - id: echoed_values
        type: string
        outputSource: 
        - echo_step/echoed
        label: Echoed Values
        doc: The string containing echoed primitive values

    steps:
      echo_step:
        run: "#clt"
        in: {}
        out:
        - echoed

  - class: CommandLineTool
    label: Echo Primitive Types Tool
    doc: A tool that echoes all primitive CWL types null, boolean, int, long, float, double, and string. The values are written to a file called `echoed.txt`.
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
        type: ["null", "string"]
        inputBinding:
          position: 0
        doc: A nullable input (null or string)
        default: null

      boolean_input:
        type: boolean
        inputBinding:
          position: 1
        doc: A boolean value
        default: true

      int_input:
        type: int
        inputBinding:
          position: 2
        doc: An integer value
        default: 42

      long_input:
        type: long
        inputBinding:
          position: 3
        doc: A long integer
        default: 1234567890123

      float_input:
        type: float
        inputBinding:
          position: 4
        doc: A floating-point number
        default: 3.14

      double_input:
        type: double
        inputBinding:
          position: 5
        doc: A double-precision float
        default: 2.7182818284

      string_input:
        type: string
        inputBinding:
          position: 6
        doc: A string input
        default: "Hello, CWL!"

    stdout: message
    outputs:
      echoed:
        outputBinding:
          glob: message
          loadContents: true
          outputEval: $(self[0].contents)
        type: string

  