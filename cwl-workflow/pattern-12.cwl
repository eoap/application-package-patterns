# Embedded URI schema derived from eoap/schemas (Copyright 2025 Terradue, Apache-2.0).
cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 1.0.0
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
      coresMax: 1
      ramMax: 512
    SchemaDefRequirement:
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
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
    NetworkAccess:
      networkAccess: true
  hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/application-package-patterns/runner:0.2.0
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
        valueFrom: |
          ${
            // Validate the length of bbox to be either 4 or 6
            var bboxLength = inputs.aoi.bbox.length;
            if (bboxLength !== 4 && bboxLength !== 6) {
              throw "Invalid bbox length: bbox must have either 4 or 6 elements.";
            }
            // Convert bbox array to a space-separated string for echo
            return ["--aoi", inputs.aoi.bbox.join(",")];
          }
    epsg:
      type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
      inputBinding:
        valueFrom: |
          ${
            var crs = inputs.epsg.crs;
            if (typeof crs !== "string") {
              throw "Invalid CRS: must be a string.";
            }
            if (crs === "CRS84") {
              return ["--epsg", "EPSG:4326"];
            } else {
              throw "Unsupported CRS: only CRS84 is currently supported.";
            }
          }
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
        valueFrom: |
          ${
            // parse the URI provided in the input
            var product_uri = inputs.collection.value;
            // Validate the URI format
            var uriPattern = /^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$/i;
            if (!uriPattern.test(product_uri)) {
              throw "Invalid URI format: " + product_uri;
            }
            // Return the URI as a string
            return ["--collection", product_uri];
          }
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
    NetworkAccess:
      networkAccess: true
  hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/application-package-patterns/runner:0.2.0
  baseCommand:
  - runner
  arguments:
  - ndi-cli
  inputs:
    rasters:
      type: Directory[]
      inputBinding:
        valueFrom: |
          ${
            var args = [];
            for (var i = 0; i < inputs.rasters.length; i++) {
              args.push("--item-" + (i + 1));
              args.push(inputs.rasters[i].path);
            }
            return args;
          }
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
        valueFrom: |
          ${
            // parse the URI provided in the input
            var product_uri = inputs.collection.value;
            // Validate the URI format
            var uriPattern = /^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$/i;
            if (!uriPattern.test(product_uri)) {
              throw "Invalid URI format: " + product_uri;
            }
            // Return the URI as a string
            return ["--collection", product_uri];
          }
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
    NetworkAccess:
      networkAccess: true
  hints:
  - class: DockerRequirement
    dockerPull: ghcr.io/eoap/application-package-patterns/runner:0.2.0
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
        valueFrom: |
          ${
            // parse the URI provided in the input
            var product_uri = inputs.collection.value;
            // Validate the URI format
            var uriPattern = /^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$/i;
            if (!uriPattern.test(product_uri)) {
              throw "Invalid URI format: " + product_uri;
            }
            // Return the URI as a string
            return ["--collection", product_uri];
          }
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
s:license: https://spdx.org/licenses/MIT.html
s:author:
- class: s:Person
  s:name: Fabrice Brito
  s:email: fabrice.brito@terradue.com
