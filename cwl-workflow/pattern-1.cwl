cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 2.0.0
s:applicationCategory: Earth Observation application package
s:keywords:
- CWL
- Workflow
- Earth Observation
s:thumbnail:
  '@type': s:ImageObject
  s:contentUrl: https://s3.waw3-2.cloudferro.com/swift/v1/stac-png/S2_L2A.jpg
  s:caption: Water bodies detected based on the NDWI and otsu threshold
  s:encodingFormat: image/jpeg
  s:height: '360'
  s:width: '640'
s:license:
  '@type': s:CreativeWork
  s:identifier: Apache-2.0
  s:name: Apache License 2.0
  s:url: https://spdx.org/licenses/Apache-2.0.html
s:softwareHelp:
- '@type': s:CreativeWork
  s:name: User Manual
  s:url: https://eoap.github.io/application-package-patterns/pattern-1/
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
$graph:
- class: Workflow
  id: pattern-1
  label: Water bodies detection based on NDWI and the otsu threshold
  doc: Water bodies detection based on NDWI and otsu threshold applied to a single
    Landsat-8/9 acquisition
  requirements:
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
      default:
        bbox:
        - -118.985
        - 38.432
        - -118.183
        - 38.938
        crs: CRS84
    epsg:
      label: EPSG code
      doc: EPSG code
      type: '#CRS'
      default: '4326'
    bands:
      label: bands used for the NDWI
      doc: bands used for the NDWI
      type: '#SpectralBand[]'
      default:
      - green
      - nir08
    item:
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
      run: '#clt'
      label: Water bodies detection
      doc: Water bodies detection based on NDWI and otsu threshold applied to a single
        Landsat-8/9 acquisition
      in:
        item: item
        aoi: aoi
        epsg: epsg
        band: bands
      out:
      - stac-catalog
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
  - pattern-1
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
    band:
      type:
      - type: array
        items: '#SpectralBand'
        inputBinding:
          prefix: --band
      label: band
      doc: band.
  outputs:
    stac-catalog:
      outputBinding:
        glob: .
      type: Directory
      label: stac-catalog
      doc: stac catalog.
  label: clt
  doc: 'application-package-patterns: clt.'
s:codeRepository: https://github.com/eoap/application-package-patterns
'@type': s:SoftwareApplication
s:name: Pattern 1 - Water bodies detection based on NDWI and the otsu threshold
s:description: "* one input parameter of type `Directory`\n* one output parameter\
  \ of type `Directory`\n\n  This scenario typically takes one input, applies an algorithm\
  \ and produces a result\n\nImplementation: delineate water bodies using NDWI and\
  \ Otsu automatic threshold taking as input a Landsat-8/9 acquisition\n"
s:dateCreated: '2025-01-01'
s:operatingSystem:
- Linux
- macOS
- macOS Server
s:softwareRequirements:
- https://cwltool.readthedocs.io/en/latest/
- https://www.python.org/
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
