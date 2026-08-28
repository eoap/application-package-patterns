$namespaces:
  s: "https://schema.org/"
  eoap: "http://oeap.github.io/schema#"
"@type": "s:SoftwareApplication"
s:name: Pattern 4 - NDVI and NDWI vegetation indexes
s:description: |
  * one input parameter of type `Directory`
  * two output parameters of type `Directory`

  This scenario takes as input an acquisition, applies two algorithms and generates two outputs.

  Implementation: process the NDVI and NDWI taking as input a Landsat-8/9 acquisition. The output include two STAC Catalogs, each with a single STAC Item
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
    id: pattern-4
    label: NDVI and NDWI vegetation indexes
    doc: NDVI and NDWI vegetation indexes from Landsat-8/9 acquisitions
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
      item:
        doc: Landsat-8/9 acquisition reference
        label: Landsat-8/9 acquisition reference
        type: Directory
    outputs:
      - id: ndvi
        doc: NDVI vegetation index
        label: NDVI vegetation index
        outputSource:
          - step/ndvi
        type: Directory
      - id: ndwi
        doc: NDWI vegetation index
        label: NDWI vegetation index
        outputSource:
          - step/ndwi
        type: Directory
    steps:
      step:
        run: "#clt"
        label: Compute NDVI and NDWI
        doc: Compute NDVI and NDWI from Landsat-8/9 acquisitions
        in:
          item: item
          aoi: aoi
          epsg: epsg
        out:
          - ndvi
          - ndwi
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
    - pattern-4
    inputs:
      item:
        type: Directory
        inputBinding:
            prefix: --input-item
      aoi:
        type: string
        inputBinding:
            prefix: --aoi
      epsg:
        type: string
        inputBinding:
            prefix: --epsg
    outputs:
      ndvi:
        outputBinding:
            glob: ndvi 
        type: Directory
      ndwi:
        outputBinding:
            glob: ndwi
        type: Directory
