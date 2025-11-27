# ## 10. multiple inputs, multiple outputs

# The CWL includes: 
# - input parameter of type `Directory[]`
# - output parameter of type `Directory[]`

# This scenario takes as input an array of acquisition, applies an algorithm to each of them. 

cwlVersion: v1.0
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf
$namespaces:
  s: https://schema.org/
  eoap: "http://oeap.github.io/schema"

s:name: NDVI and NDWI vegetation indexes
s:description: NDVI and NDWI vegetation indexes from Landsat-8/9 acquisitions.
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
  - class: Workflow
    id: pattern-10
    label: NDVI and NDWI vegetation indexes
    doc: NDVI and NDWI vegetation indexes from Landsat-8/9 acquisitions
    requirements:
      SubworkflowFeatureRequirement: {}
      ScatterFeatureRequirement: {}
    # hints:
    # - eoap:JSONSchemaHint
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
      indexes:
        label: indexes
        doc: indexes to compute
        type: string[]
        default: ["ndvi", "ndwi"]
      items:
        doc: Landsat-8/9 acquisition reference
        label: Landsat-8/9 acquisition reference
        type: Directory[]

    outputs:
    - id: vegetation_indexes
      label: Vegetation indexes
      doc: Vegetation indexes from Landsat-8/9 acquisitions
      outputSource:
        - flatten/flat
      type:
        type: array
        items: Directory
    steps:
      subworkflow:
        run: "#vegetation_indexes"
        in:
          item: items
          aoi: aoi
          epsg: epsg
          indexes: indexes
        out:
          - vegetation_indexes
        scatter: 
        - item
        scatterMethod: dotproduct
      
      flatten:
        run: "#flatten_array"
        in:
          nested: subworkflow/vegetation_indexes
        out:
          - flat

  - class: Workflow
    id: vegetation_indexes
    label: NDVI and NDWI vegetation indexes
    doc: NDVI and NDWI vegetation indexes
    requirements:
      ScatterFeatureRequirement: {}
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
      indexes:
        label: indexes
        doc: indexes to compute
        type: string[]
        default: ["ndvi", "ndwi"]
      item:
        doc: Reference to a STAC item
        label: STAC item reference
        type: Directory
    outputs:
      - id: vegetation_indexes
        doc: Vegetation indexes
        label: Vegetation indexes
        outputSource:
          - step/vegetation_index
        type: Directory[]
    steps:
      step:
        run: "#clt"
        in:
          item: item
          aoi: aoi
          epsg: epsg
          index: indexes
        out:
          - vegetation_index
        scatter: index
        scatterMethod: dotproduct

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
    - pattern-5
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

      index:
        type: string
        inputBinding:
            prefix: --vegetation-index

    outputs:
      vegetation_index:
        outputBinding:
            glob: . 
        type: Directory


  - class: ExpressionTool
    id: flatten_array
    label: Flatten Directory[][] → Directory[]
    inputs:
      - id: nested
        type:
          type: array
          items:
            type: array
            items: Directory
    outputs:
      - id: flat
        type:
          type: array
          items: Directory
    expression: |
      ${ return { flat: [].concat(...inputs.nested) }; }
    requirements:
      - class: InlineJavascriptRequirement