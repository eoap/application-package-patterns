$namespaces:
  s: "https://schema.org/"
"@type": "s:SoftwareApplication"
s:name: Astonishing Stage-in from URL
s:description: Stages in a file from a given URL
s:dateCreated: "2025-01-01"
s:license:
  "@type": "s:CreativeWork"
  s:identifier: Apache-2.0
  s:name: Apache License 2.0
  s:url: "https://spdx.org/licenses/Apache-2.0.html"
s:keywords:
  - CWL
  - Workflow
  - Earth Observation
s:operatingSystem:
  - Linux
  - macOS
  - macOS Server
s:softwareRequirements:
  - "https://cwltool.readthedocs.io/en/latest/"
  - "https://www.python.org/"
s:softwareVersion: 1.0.0
s:softwareHelp:
  - "@type": "s:CreativeWork"
    s:name: User Manual
    s:url: "https://eoap.github.io/application-package-patterns/pattern-1/"
s:publisher:
  "@type": "s:Organization"
  s:name: Make Earth Observation Great Again
  s:email: "info@meoga.com"
  s:identifier: "https://ror.org/9999cx000"
s:author:
  - "@type": "s:Role"
    s:roleName: Project administration
    s:startDate: "2025-01-01"
    s:additionalType: "https://credit.niso.org/contributor-roles/project-administration/"
    s:author:
      "@type": "s:Person"
      s:givenName: Lois
      s:familyName: Lane
      s:email: "lois.lane@meoga.com"
      s:identifier: "https://orcid.org/0000-9999-0000-9999"
      s:affiliation:
        "@type": "s:Organization"
        s:name: Make Earth Observation Great Again
        s:email: "info@meoga.com"
        s:identifier: "https://ror.org/9999cx000"
  - "@type": "s:Role"
    s:roleName: Supervision
    s:startDate: "2025-01-01"
    s:additionalType: "https://credit.niso.org/contributor-roles/supervision/"
    s:author:
      "@type": "s:Person"
      s:givenName: Clark
      s:familyName: Kent
      s:email: "clark.kent@meoga.com"
      s:identifier: "https://orcid.org/9999-0000-9999-0000"
      s:affiliation:
        "@type": "s:Organization"
        s:name: Make Earth Observation Great Again
        s:email: "info@meoga.com"
        s:identifier: "https://ror.org/9999cx000"
s:contributor:
  - "@type": "s:Role"
    s:roleName: Software
    s:startDate: "2025-01-01"
    s:additionalType: "https://credit.niso.org/contributor-roles/software/"
    s:contributor:
      "@type": "s:Person"
      s:givenName: Lex
      s:familyName: Luthor
      s:email: "lex.luthor@meoga.com"
      s:affiliation:
        "@type": "s:Organization"
        s:name: Make Earth Observation Great Again
        s:email: "info@meoga.com"
        s:identifier: "https://ror.org/9999cx000"

cwlVersion: v1.0
class: CommandLineTool
id: my-asthonishing-stage-in-file
label: "Astonishing Stage-in from URL"
doc: "Stages in a file from a given URL"
inputs:
  reference:
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    doc: "An URL to stage" 
    label: "Reference URL"
  another_input:
    type: string
    doc: "An additional input for demonstration purposes"
    label: "Another Input"
outputs:
  staged:
    type: File
    doc: "The staged file"
    label: "Staged File"
    outputBinding:
      glob: staged
baseCommand: 
- python
- stage.py
arguments:
- $( inputs.reference.value )
- $( inputs.another_input ) # This is an additional input to demonstrate the use of multiple inputs
requirements:
  NetworkAccess:
    networkAccess: true
  SchemaDefRequirement:
    types:
    - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
  DockerRequirement:
    dockerPull: ghcr.io/eoap/application-package-patterns/runner:0.2.0
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: stage.py
        entry: |-
          import sys
          import requests
          import planetary_computer

          href = sys.argv[1]

          signed_url = planetary_computer.sign(href)
          output_path = "staged"

          response = requests.get(signed_url, stream=True)
          response.raise_for_status()  # Raise an error for bad status codes

          with open(output_path, "wb") as f:
              for chunk in response.iter_content(chunk_size=8192):
                  f.write(chunk)

          print(f"Downloaded to {output_path}")

          empty_arg = sys.argv[2]
          
          

