cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 2.0.0
$graph:
- class: Workflow
  id: pattern-12
  label: Water body detection based on NDWI and the otsu threshold
  doc: Water bodies detection based on NDWI and otsu threshold applied to Sentinel-2
    or Landsat-9 staged acquisitions
  requirements:
    ScatterFeatureRequirement: {}
    SchemaDefRequirement:
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
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
    InlineJavascriptRequirement: {}
  inputs:
    aoi:
      label: area of interest
      doc: area of interest as a bounding box
      type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
    bands:
      label: bands used for the NDWI
      doc: bands used for the NDWI
      type: '#SpectralBand[]'
      default:
      - green
      - nir
    item:
      doc: Landsat-8/9 acquisition reference
      label: Landsat-8/9 acquisition reference
      type: Directory
    cropped-collection:
      label: cropped reflectances STAC Collection
      doc: STAC Collection URL for the cropped reflectances
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    ndwi-collection:
      label: NDWI STAC Collection
      doc: STAC Collection URL for the NDWI
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    water-bodies-collection:
      label: Water bodies STAC Collection
      doc: STAC Collection URL for the water bodies
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
  outputs:
  - id: cropped
    label: Cropped reflectances
    doc: Cropped reflectances
    outputSource:
    - node_crop/cropped
    type: Directory[]
  - id: ndwi
    label: Normalized Difference Water Index
    doc: Normalized Difference Water Index calculated from the input bands
    outputSource:
    - node_normalized_difference/ndwi
    type: Directory
  - id: water_bodies
    label: Water bodies detected
    doc: Water bodies detected based on the NDWI and otsu threshold
    outputSource:
    - node_otsu/water_bodies
    type: Directory
  steps:
    node_crop:
      run: '#crop'
      in:
        item: item
        aoi: aoi
        epsg: aoi
        band: bands
        collection: cropped-collection
      out:
      - cropped
      scatter: band
      scatterMethod: dotproduct
    node_normalized_difference:
      run: '#norm_diff'
      in:
        rasters:
          source: node_crop/cropped
        item: item
        collection: ndwi-collection
      out:
      - ndwi
    node_otsu:
      run: '#otsu'
      in:
        raster:
          source: node_normalized_difference/ndwi
        item: item
        collection: water-bodies-collection
      out:
      - water_bodies
- class: CommandLineTool
  id: crop
  requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef:
        PATH: /app/envs/runner/bin
    ResourceRequirement:
      coresMin: 1
      ramMin: 2048
      coresMax: 1
      ramMax: 2048
    SchemaDefRequirement:
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
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
    NetworkAccess:
      networkAccess: true
  hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/application-package-patterns/runner@sha256:e9650bd0a6c5fc25ee5e52fcfa5cad8e77bb75582ce3a628ee43dfd5f3155ab0
  baseCommand:
  - runner
  arguments:
  - crop-cli
  inputs:
    item:
      type: Directory
      inputBinding:
        prefix: --input-item
      label: item
      doc: item.
    aoi:
      type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
      label: Area of interest
      doc: Area of interest defined as a bounding box
      inputBinding:
        valueFrom: "${\n  // Validate the length of bbox to be either 4 or 6\n  var\
          \ bboxLength = inputs.aoi.bbox.length;\n  if (bboxLength !== 4 && bboxLength\
          \ !== 6) {\n    throw \"Invalid bbox length: bbox must have either 4 or\
          \ 6 elements.\";\n  }\n  // Convert bbox array to a space-separated string\
          \ for echo\n  return [\"--aoi\", inputs.aoi.bbox.join(\",\")];\n}\n"
    epsg:
      type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
      inputBinding:
        valueFrom: "${\n  var crs = inputs.epsg.crs;\n  if (typeof crs !== \"string\"\
          ) {\n    throw \"Invalid CRS: must be a string.\";\n  }\n  if (crs === \"\
          CRS84\") {\n    return [\"--epsg\", \"EPSG:4326\"];\n  } else {\n    throw\
          \ \"Unsupported CRS: only CRS84 is currently supported.\";\n  }\n}\n"
      label: epsg
      doc: epsg.
    band:
      type: '#SpectralBand'
      inputBinding:
        prefix: --band
      label: band
      doc: band.
    collection:
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      inputBinding:
        valueFrom: "${\n  // parse the URI provided in the input\n  var product_uri\
          \ = inputs.collection.value;\n  // Validate the URI format\n  var uriPattern\
          \ = /^(https?|ftp):\\/\\/[^\\s/$.?#].[^\\s]*$/i;\n  if (!uriPattern.test(product_uri))\
          \ {\n    throw \"Invalid URI format: \" + product_uri;\n  }\n  // Return\
          \ the URI as a string\n  return [\"--collection\", product_uri];\n}\n"
      label: collection
      doc: collection.
  outputs:
    cropped:
      outputBinding:
        glob: .
      type: Directory
      label: cropped
      doc: cropped.
  label: crop
  doc: 'application-package-patterns: crop.'
- class: CommandLineTool
  id: norm_diff
  requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef:
        PATH: /app/envs/runner/bin
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
    NetworkAccess:
      networkAccess: true
  hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/application-package-patterns/runner@sha256:e9650bd0a6c5fc25ee5e52fcfa5cad8e77bb75582ce3a628ee43dfd5f3155ab0
  baseCommand:
  - runner
  arguments:
  - ndi-cli
  inputs:
    rasters:
      type: Directory[]
      inputBinding:
        valueFrom: "${\n  var args = [];\n  for (var i = 0; i < inputs.rasters.length;\
          \ i++) {\n    args.push(\"--item-\" + (i + 1));\n    args.push(inputs.rasters[i].path);\n\
          \  }\n  return args;\n}\n"
      label: rasters
      doc: rasters.
    item:
      type: Directory
      inputBinding:
        prefix: --item
      label: item
      doc: item.
    collection:
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      inputBinding:
        valueFrom: "${\n  // parse the URI provided in the input\n  var product_uri\
          \ = inputs.collection.value;\n  // Validate the URI format\n  var uriPattern\
          \ = /^(https?|ftp):\\/\\/[^\\s/$.?#].[^\\s]*$/i;\n  if (!uriPattern.test(product_uri))\
          \ {\n    throw \"Invalid URI format: \" + product_uri;\n  }\n  // Return\
          \ the URI as a string\n  return [\"--collection\", product_uri];\n}\n"
      label: collection
      doc: collection.
  outputs:
    ndwi:
      outputBinding:
        glob: .
      type: Directory
      label: ndwi
      doc: ndwi.
  label: norm_diff
  doc: 'application-package-patterns: norm_diff.'
- class: CommandLineTool
  id: otsu
  requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef:
        PATH: /app/envs/runner/bin
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
    NetworkAccess:
      networkAccess: true
  hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/application-package-patterns/runner@sha256:e9650bd0a6c5fc25ee5e52fcfa5cad8e77bb75582ce3a628ee43dfd5f3155ab0
  baseCommand:
  - runner
  arguments:
  - otsu-cli
  inputs:
    raster:
      type: Directory
      inputBinding:
        prefix: --input-ndi
      label: raster
      doc: raster.
    item:
      type: Directory
      inputBinding:
        prefix: --item
      label: item
      doc: item.
    collection:
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      inputBinding:
        valueFrom: "${\n  // parse the URI provided in the input\n  var product_uri\
          \ = inputs.collection.value;\n  // Validate the URI format\n  var uriPattern\
          \ = /^(https?|ftp):\\/\\/[^\\s/$.?#].[^\\s]*$/i;\n  if (!uriPattern.test(product_uri))\
          \ {\n    throw \"Invalid URI format: \" + product_uri;\n  }\n  // Return\
          \ the URI as a string\n  return [\"--collection\", product_uri];\n}\n"
      label: collection
      doc: collection.
  outputs:
    water_bodies:
      outputBinding:
        glob: .
      type: Directory
      label: water_bodies
      doc: water bodies.
  label: otsu
  doc: 'application-package-patterns: otsu.'
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
s:name: Pattern 12 - Water body detection based on NDWI and the otsu threshold
s:description: 'This patterns publishes all products generated by all steps

  '
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
