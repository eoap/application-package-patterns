# Embedded URI schema derived from eoap/schemas (Copyright 2025 Terradue, Apache-2.0).
cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.0.0
s:applicationCategory: Earth Observation application package
s:additionalProperty:
- '@type': s:PropertyValue
  s:name: application-type
  s:value: vegetation-index
- '@type': s:PropertyValue
  s:name: domain
  s:value: agriculture
$graph:
- class: Workflow
  id: pattern-6
  label: NDVI mean
  doc: NDVI mean from Landsat-8/9 acquisitions
  requirements:
    ScatterFeatureRequirement: {}
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
    aoi:
      label: area of interest
      doc: area of interest as a bounding box
      type: '#BBox'
    epsg:
      label: EPSG code
      doc: EPSG code
      type: '#CRS'
      default: '4326'
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
      run: '#clt'
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
      label: item
      doc: item.
    aoi:
      type: '#BBox'
      inputBinding:
        prefix: --aoi
        valueFrom: $(self.bbox.join(","))
      label: aoi
      doc: aoi.
    epsg:
      type: '#CRS'
      inputBinding:
        prefix: --epsg
        valueFrom: '$(self === "native" ? self : "EPSG:" + self)'
      label: epsg
      doc: epsg.
  stdout: message
  outputs:
    mean:
      outputBinding:
        glob: message
        loadContents: true
        outputEval: $(parseFloat(self[0].contents))
      type: float
      label: mean
      doc: mean.
  label: clt
  doc: 'application-package-patterns: clt.'
s:codeRepository: https://github.com/eoap/application-package-patterns
s:license: https://spdx.org/licenses/MIT.html
s:author:
- class: s:Person
  s:name: Fabrice Brito
  s:email: fabrice.brito@terradue.com
