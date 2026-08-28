$namespaces:
  s: "https://schema.org/"
  eoap: "http://oeap.github.io/schema#"
"@type": "s:SoftwareApplication"
s:name: Water bodies detection based on NDWI and the otsu threshold
s:description: |
  NDVI mean from Landsat-8/9 acquisitions  

  6. one input, no output

  The CWL includes: 
  - one input parameter of type `Directory`
  - there are no output parameters of type `Directory`

  This corner-case scenario takes as input an acquisition, applies an algorithm and generates an output that is not a STAC Catalog

  Implementation: derive the NDVI mean taking as input a Landsat-9 acquisition
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
    id: pattern-6
    label: NDVI mean
    doc: NDVI mean from Landsat-8/9 acquisitions
    requirements:
      ScatterFeatureRequirement: {}
    hints:
    - class: eoap:JSONSchemaHint
    inputs:
      aoi:
        label: area of interest
        doc: area of interest as a bounding box
        type: string
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
      - id: mean
        doc: Vegetation index mean
        label: Vegetation index mean
        outputSource:
          - step/mean
        type: float
    steps:
      step:
        run: "#clt"
        label: Compute NDVI mean
        doc: Compute NDVI mean from the Landsat-8/9 acquisition
        in:
          item: item
          aoi: aoi
          epsg: epsg
        out:
          - mean

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
    - pattern-6
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
    stdout: message
    outputs:
      mean:
        outputBinding:
          glob: message
          loadContents: true
          outputEval: $(parseFloat(self[0].contents))
        type: float
