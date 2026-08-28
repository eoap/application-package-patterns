cwlVersion: v1.0

$namespaces:
  s: "https://schema.org/"
s:name: Astonishing Stage-in from STAC Item
s:description: Stages in a STAC Item from a given URL
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

class: CommandLineTool
id: my-asthonishing-stage-in-directory
label: "Astonishing Stage-in from STAC Item"
doc: "Stages in a STAC Item from a given URL"
inputs:
  reference:
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    doc: "A STAC Item to stage" 
    label: "STAC Item URL"
  another_input:
    type: string
    doc: "An additional input for demonstration purposes"
    label: "Another Input"
outputs:
  staged:
    type: Directory
    label: "Staged Directory"
    doc: "The directory containing the staged STAC Item as a STAC catalog"
    outputBinding:
      glob: .
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
    dockerPull: ghcr.io/eoap/mastering-app-package/stage:1.0.0
  InlineJavascriptRequirement: {}
  InitialWorkDirRequirement:
    listing:
      - entryname: stage.py
        entry: |-
          import pystac
          import stac_asset
          import asyncio
          import os
          import sys

          config = stac_asset.Config(warn=True)

          async def main(href: str):
              
              item = pystac.read_file(href)
              
              os.makedirs(item.id, exist_ok=True)
              cwd = os.getcwd()
              
              os.chdir(item.id)
              item = await stac_asset.download_item(item=item, directory=".", config=config)
              os.chdir(cwd)
              
              cat = pystac.Catalog(
                  id="catalog",
                  description=f"catalog with staged {item.id}",
                  title=f"catalog with staged {item.id}",
              )
              cat.add_item(item)
              
              cat.normalize_hrefs("./")
              cat.save(catalog_type=pystac.CatalogType.SELF_CONTAINED)

              return cat

          href = sys.argv[1]
          empty_arg = sys.argv[2]
          
          cat = asyncio.run(main(href))


