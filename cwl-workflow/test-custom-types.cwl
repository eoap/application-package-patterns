cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:softwareVersion: 2.0.0
$graph:
- id: test-custom-types
  class: Workflow
  label: Echo custom CWL Types
  doc: This workflow demonstrates usage of all CWL primitive types. It runs the `echo-tool`
    with default values and captures the output in a file.
  requirements:
    InlineJavascriptRequirement: {}
    SchemaDefRequirement:
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
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
      - type: record
        name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#DateTime
        fields:
        - name: value
          type: string
  inputs:
  - id: bbox
    type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
    label: Area of interest
    doc: Area of interest defined as a bounding box
  - id: point_of_interest
    type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Point
    label: Point of Interest
    doc: Point of interest defined in GeoJSON format
  - id: aoi
    type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature
    label: Area of interest
    doc: Area of interest defined in GeoJSON format
  - id: start_time
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#DateTime
    label: Start Time
    doc: Start time in ISO 8601 format
  - id: product_uri
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    label: Product URI
    doc: Product URI in string format
  outputs:
  - id: echoed_values
    type: string
    outputSource:
    - echo_step/echoed
    label: Echoed Values
    doc: The string containing echoed values
  steps:
    echo_step:
      run: '#clt'
      in:
        bbox: bbox
        point_of_interest: point_of_interest
        aoi: aoi
        start_time: start_time
        product_uri: product_uri
      out:
      - echoed
- class: CommandLineTool
  label: Echo Tool
  doc: A tool that echoes the inputs.
  id: clt
  requirements:
    InlineJavascriptRequirement: {}
    EnvVarRequirement:
      envDef:
        PATH: $PATH:/app/envs/runner/bin:/usr/bin
    ResourceRequirement:
      coresMin: 1
      ramMin: 2048
      coresMax: 1
      ramMax: 2048
    DockerRequirement:
      dockerPull: ghcr.io/eoap/application-package-patterns/runner@sha256:e9650bd0a6c5fc25ee5e52fcfa5cad8e77bb75582ce3a628ee43dfd5f3155ab0
    SchemaDefRequirement:
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
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
      - type: record
        name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#DateTime
        fields:
        - name: value
          type: string
  baseCommand:
  - echo
  arguments:
  - $(inputs.bbox)
  - $(inputs.point_of_interest)
  - $(inputs.aoi)
  - $(inputs.start_time)
  - $(inputs.product_uri)
  inputs:
    bbox:
      type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
      label: Area of interest
      doc: Area of interest defined as a bounding box
      inputBinding:
        position: 1
        valueFrom: "${\n  // Validate the length of bbox to be either 4 or 6\n  var\
          \ bboxLength = inputs.bbox.bbox.length;\n  if (bboxLength !== 4 && bboxLength\
          \ !== 6) {\n    throw \"Invalid bbox length: bbox must have either 4 or\
          \ 6 elements.\";\n  }\n  // Convert bbox array to a space-separated string\
          \ for echo\n  return \"Bbox: \" + inputs.bbox.bbox.join(\" \") + \" CRS:\
          \ \" + inputs.bbox.crs;\n}\n"
    point_of_interest:
      type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Point
      label: Point of Interest
      doc: Point of interest defined in GeoJSON format
      inputBinding:
        position: 2
        valueFrom: "${\n  // Validate if type is Point\n  if (inputs.point_of_interest.type\
          \ !== \"Point\") {\n    throw \"Invalid GeoJSON type: expected \\\"Point\\\
          \", got \\\"\" + inputs.point_of_interest.type + \"\\\"\";\n  }\n  var coordinates\
          \ = inputs.point_of_interest.coordinates;\n  return \"Point Coordinates:\
          \ \" + coordinates.join(\", \");\n}\n"
    aoi:
      type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature
      label: Area of interest
      doc: Area of interest defined in GeoJSON format
      inputBinding:
        position: 3
        valueFrom: "${\n  // Validate if type is Feature\n  if (inputs.aoi.type !==\
          \ \"Feature\") {\n    throw \"Invalid GeoJSON type: expected \\\"Feature\\\
          \", got \\\"\" + inputs.aoi.type + \"\\\"\";\n  }\n  // get the Feature\
          \ geometry type\n  return \"Feature with id \\\"\" + inputs.aoi.id + \"\\\
          \" is of type: \" + inputs.aoi.geometry.type;\n}\n"
    start_time:
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#DateTime
      label: Start Time
      doc: Start time in ISO 8601 format
      inputBinding:
        position: 4
        valueFrom: "${\n  // Parse ISO datetime and extract parts\n  var date = new\
          \ Date(inputs.start_time.value);\n  if (isNaN(date.getTime())) {\n    throw\
          \ \"Invalid ISO 8601 date format for start_time.\";\n  }\n  var dateParts\
          \ = [\n    \"Date Breakdown:\",\n    \"Year: \" + date.getUTCFullYear(),\n\
          \    \"Month: \" + (date.getUTCMonth() + 1),\n    \"Day: \" + date.getUTCDate(),\n\
          \    \"Hour: \" + date.getUTCHours(),\n    \"Minute: \" + date.getUTCMinutes(),\n\
          \    \"Second: \" + date.getUTCSeconds()\n  ].join(\"\\n * \");\n  return\
          \ dateParts;\n}\n"
    product_uri:
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      label: Product URI
      doc: Product URI in string format
      inputBinding:
        position: 5
        valueFrom: "${\n  // parse the URI provided in the input\n  var product_uri\
          \ = inputs.product_uri.value;\n  // Validate the URI format\n  var uriPattern\
          \ = /^(https?|ftp):\\/\\/[^\\s/$.?#].[^\\s]*$/i;\n  if (!uriPattern.test(product_uri))\
          \ {\n    throw \"Invalid URI format: \" + product_uri;\n  }\n  // Return\
          \ the URI as a string\n  return \"Product URI: \" + product_uri;\n}\n"
  stdout: message
  outputs:
    echoed:
      outputBinding:
        glob: message
        loadContents: true
        outputEval: $(self[0].contents)
      type: string
      label: echoed
      doc: echoed.
s:codeRepository: https://github.com/eoap/application-package-patterns
s:license:
  '@type': s:CreativeWork
  s:identifier: Apache-2.0
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
s:name: Echo custom CWL Types
s:description: This workflow demonstrates usage of all CWL primitive types. It runs
  the `echo-tool` with default values and captures the output in a file.
s:dateCreated: '2025-01-01'
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
s:softwareHelp:
- '@type': s:CreativeWork
  s:name: User Manual
  s:url: https://eoap.github.io/application-package-patterns/
s:publisher:
  '@type': s:Organization
  s:name: Make Earth Observation Great Again
  s:email: info@meoga.com
  s:identifier: https://ror.org/9999cx000
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
