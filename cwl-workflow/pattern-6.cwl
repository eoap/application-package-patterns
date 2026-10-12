cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 2.0.0
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
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
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
    ResourceRequirement:
      coresMin: 1
      ramMin: 2048
      coresMax: 1
      ramMax: 2048
    SchemaDefRequirement:
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
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
      dockerPull: ghcr.io/eoap/application-package-patterns/runner@sha256:e9650bd0a6c5fc25ee5e52fcfa5cad8e77bb75582ce3a628ee43dfd5f3155ab0
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
s:license:
  '@type': s:CreativeWork
  s:identifier: Apache-2.0
  s:name: Apache License 2.0
  s:url: https://spdx.org/licenses/Apache-2.0.html
s:author:
- '@type': s:Role
  s:roleName: Project administration
  s:startDate: '2025-01-01'
  s:additionalType: https://credit.niso.org/contributor-roles/project-administration/
  s:author:
    '@type': s:Person
    s:givenName: Lois
    s:familyName: Lane
    s:email: lois.lane@meoga.com
    s:identifier: https://orcid.org/0000-9999-0000-9999
    s:affiliation:
      '@type': s:Organization
      s:name: Make Earth Observation Great Again
      s:email: info@meoga.com
      s:identifier: https://ror.org/9999cx000
- '@type': s:Role
  s:roleName: Supervision
  s:startDate: '2025-01-01'
  s:additionalType: https://credit.niso.org/contributor-roles/supervision/
  s:author:
    '@type': s:Person
    s:givenName: Clark
    s:familyName: Kent
    s:email: clark.kent@meoga.com
    s:identifier: https://orcid.org/9999-0000-9999-0000
    s:affiliation:
      '@type': s:Organization
      s:name: Make Earth Observation Great Again
      s:email: info@meoga.com
      s:identifier: https://ror.org/9999cx000
'@type': s:SoftwareApplication
s:name: Water bodies detection based on NDWI and the otsu threshold
s:description: "NDVI mean from Landsat-8/9 acquisitions  \n\n6. one input, no output\n\
  \nThe CWL includes: \n- one input parameter of type `Directory`\n- there are no\
  \ output parameters of type `Directory`\n\nThis corner-case scenario takes as input\
  \ an acquisition, applies an algorithm and generates an output that is not a STAC\
  \ Catalog\n\nImplementation: derive the NDVI mean taking as input a Landsat-9 acquisition\n"
s:dateCreated: '2025-01-01'
s:keywords:
- CWL
- Workflow
- Earth Observation
s:operatingSystem:
- Linux
- macOS
- macOS Server
s:softwareRequirements:
- https://cwltool.readthedocs.io/en/latest/
- https://www.python.org/
s:softwareHelp:
- '@type': s:CreativeWork
  s:name: User Manual
  s:url: https://eoap.github.io/application-package-patterns/pattern-1/
s:publisher:
  '@type': s:Organization
  s:name: Make Earth Observation Great Again
  s:email: info@meoga.com
  s:identifier: https://ror.org/9999cx000
s:contributor:
- '@type': s:Role
  s:roleName: Software
  s:startDate: '2025-01-01'
  s:additionalType: https://credit.niso.org/contributor-roles/software/
  s:contributor:
    '@type': s:Person
    s:givenName: Lex
    s:familyName: Luthor
    s:email: lex.luthor@meoga.com
    s:affiliation:
      '@type': s:Organization
      s:name: Make Earth Observation Great Again
      s:email: info@meoga.com
      s:identifier: https://ror.org/9999cx000
