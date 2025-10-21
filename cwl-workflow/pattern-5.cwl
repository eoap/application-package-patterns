# ## 5. one input/scatter on outputs

# The CWL includes: 
# - one input parameter of type `Directory`
# - scatter on an output parameter of type `Directory[]`

# This scenario takes as input an acquisition, applies an algorithm and generates several outputs

# Implementation: process the NDVI and NDWI taking as input a Landsat-9 acquisition and generating a stack of STAC Catalogs


cwlVersion: v1.0
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.0.0
s:applicationCategory: "Earth Observation application package"
s:additionalProperty:
  - @type: s:PropertyValue
    s:name: application-type
    s:value: vegetation-index
  - @type: s:PropertyValue
    s:name: domain
    s:value: agriculture
schemas:
  - http://schema.org/version/9.0/schemaorg-current-http.rdf
$graph:
  - class: Workflow
    id: pattern-5
    label: NDVI and NDWI vegetation indexes
    doc: NDVI and NDWI vegetation indexes from Landsat-8/9 acquisitions
    requirements:
      ScatterFeatureRequirement: {}
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
      item:
        doc: Landsat-8/9 acquisition reference
        label: Landsat-8/9 acquisition reference
        type: Directory
    outputs:
      - id: vegetation_indexes
        doc: Vegetation indexes from Landsat-8/9 acquisitions
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


