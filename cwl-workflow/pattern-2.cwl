$namespaces:
  s: "https://schema.org/"
"@type": "s:SoftwareApplication"
s:name: Pattern 2 - Water bodies detection based on NDWI and the otsu threshold
s:description: |
  * two input parameters of type `Directory`
  * one output parameter of type `Directory`

  This scenario typically takes as input one pre-event acquisition, one post-even acquisition, applies an algorithm and produces a result

  Implementation: delineate water bodies using NDWI and Otsu automatic threshold taking as input two Landsat-8/9 acquisitions
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
$graph:
  - class: Workflow
    id: pattern-2
    label: Water bodies detection based on NDWI and the otsu threshold
    doc: Water bodies detection based on NDWI and otsu threshold applied to a pair of Landsat-8/9 acquisitions
    requirements: []
    hints:
    - class: eoap:JSONSchemaHint
    inputs:
      aoi:
        label: area of interest
        doc: area of interest as a bounding box
        type: string
        default: "-118.985,38.432,-118.183,38.938"
      epsg:
        label: EPSG code
        doc: EPSG code
        type: string
        default: "EPSG:4326"
      bands:
        label: bands used for the NDWI
        doc: bands used for the NDWI
        type: string[]
        default: ["green", "nir08"]
      item_1:
        doc: Landsat-8/9 acquisition reference
        label: Landsat-8/9 acquisition reference
        type: Directory
      item_2:
        doc: Landsat-8/9 acquisition reference
        label: Landsat-8/9 acquisition reference
        type: Directory
    outputs:
      - id: water_bodies
        label: Water bodies detected
        doc: Water bodies detected based on the NDWI and otsu threshold
        outputSource:
          - step/stac-catalog
        type: Directory
    steps:
      step:
        run: "#clt"
        label: Detect water bodies
        doc: Detect water bodies based on the NDWI and otsu threshold from Landsat-
        in:
          item_1: item_1
          item_2: item_2
          aoi: aoi
          epsg: epsg
          band: bands
        out:
          - stac-catalog
  - class: CommandLineTool
    id: clt
    requirements:
        InlineJavascriptRequirement: {}
        EnvVarRequirement:
          envDef:
            PATH: $PATH:/app/envs/runner/bin
        ResourceRequirement:
          coresMax: 1
          ramMax: 512
    hints:
      DockerRequirement:
        dockerPull: ghcr.io/eoap/application-package-patterns/runner:0.2.0
    baseCommand:
    - runner
    arguments:
    - pattern-2
    inputs:
      item_1:
        type: Directory
        inputBinding:
            prefix: --input-item-1
      item_2:
        type: Directory
        inputBinding:
            prefix: --input-item-2
      aoi:
        type: string
        inputBinding:
            prefix: --aoi
      epsg:
        type: string
        inputBinding:
            prefix: --epsg
      band:
        type:
          - type: array
            items: string
            inputBinding:
              prefix: '--band'

    outputs:
      stac-catalog:
        outputBinding:
            glob: .
        type: Directory

