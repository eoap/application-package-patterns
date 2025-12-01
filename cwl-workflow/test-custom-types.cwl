cwlVersion: v1.0
schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf
$namespaces:
  s: https://schema.org/
  eoap: "http://oeap.github.io/schema"

s:name: Echo custom CWL Types
s:description: This workflow demonstrates usage of all CWL primitive types. It runs the `echo-tool` with default values and captures the output in a file.
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
  - id: test-custom-types
    class: Workflow
    label: Echo custom CWL Types
    doc: This workflow demonstrates usage of all CWL primitive types. It runs the `echo-tool` with default values and captures the output in a file.
    requirements:
    - class: InlineJavascriptRequirement
    - class: SchemaDefRequirement
      types:
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
      - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
    hints:
    - class: eoap:JSONSchemaHint
    inputs:
    - id: bbox
      type: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox
      label: "Area of interest"
      doc: "Area of interest defined as a bounding box"
    
    - id: point_of_interest
      type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Point
      label: "Point of Interest"
      doc: "Point of interest defined in GeoJSON format"

    - id: aoi
      type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature
      label: "Area of interest"
      doc: "Area of interest defined in GeoJSON format"

    - id: start_time
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#DateTime
      label: "Start Time"
      doc: "Start time in ISO 8601 format"

    - id: product_uri
      type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      label: "Product URI"
      doc: "Product URI in string format"

    outputs:
      - id: echoed_values
        type: string
        outputSource: 
        - echo_step/echoed
        label: Echoed Values
        doc: The string containing echoed values

    steps:
      echo_step:
        run: "#clt"
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
        coresMax: 1
        ramMax: 256
    
      DockerRequirement:
        dockerPull: ghcr.io/eoap/application-package-patterns/runner@sha256:db75818d12e3ea05b583ff53e32cd291fc3d40a62ae8cb53d51573c56813f1b6
      SchemaDefRequirement:
        types:
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml
          - $import: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml
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
        label: "Area of interest"
        doc: "Area of interest defined as a bounding box"
        inputBinding:
          position: 1
          valueFrom: |
            ${
              // Validate the length of bbox to be either 4 or 6
              var bboxLength = inputs.bbox.bbox.length;
              if (bboxLength !== 4 && bboxLength !== 6) {
                throw "Invalid bbox length: bbox must have either 4 or 6 elements.";
              }
              // Convert bbox array to a space-separated string for echo
              return "Bbox: " + inputs.bbox.bbox.join(" ") + " CRS: " + inputs.bbox.crs;
            }
        
      
      point_of_interest:
        type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Point
        label: "Point of Interest"
        doc: "Point of interest defined in GeoJSON format"
        inputBinding:
          position: 2
          valueFrom: |
            ${
              // Validate if type is Point
              if (inputs.point_of_interest.type !== "Point") {
                throw "Invalid GeoJSON type: expected \"Point\", got \"" + inputs.point_of_interest.type + "\"";
              }
              var coordinates = inputs.point_of_interest.coordinates;
              return "Point Coordinates: " + coordinates.join(", ");
            }
      aoi:
        type: https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#Feature
        label: "Area of interest"
        doc: "Area of interest defined in GeoJSON format"
        inputBinding:
          position: 3
          valueFrom: |
            ${
              // Validate if type is Feature
              if (inputs.aoi.type !== "Feature") {
                throw "Invalid GeoJSON type: expected \"Feature\", got \"" + inputs.aoi.type + "\"";
              }
              // get the Feature geometry type
              return "Feature with id \"" + inputs.aoi.id + "\" is of type: " + inputs.aoi.geometry.type;
            }

      start_time:
        type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#DateTime
        label: "Start Time"
        doc: "Start time in ISO 8601 format"
        inputBinding:
          position: 4
          valueFrom: |
            ${
              // Parse ISO datetime and extract parts
              var date = new Date(inputs.start_time.value);
              if (isNaN(date.getTime())) {
                throw "Invalid ISO 8601 date format for start_time.";
              }
              var dateParts = [
                "Date Breakdown:",
                "Year: " + date.getUTCFullYear(),
                "Month: " + (date.getUTCMonth() + 1),
                "Day: " + date.getUTCDate(),
                "Hour: " + date.getUTCHours(),
                "Minute: " + date.getUTCMinutes(),
                "Second: " + date.getUTCSeconds()
              ].join("\n * ");
              return dateParts;
            }

      product_uri:
        type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
        label: "Product URI"
        doc: "Product URI in string format"
        inputBinding:
          position: 5
          valueFrom: |
            ${
              // parse the URI provided in the input
              var product_uri = inputs.product_uri.value;
              // Validate the URI format
              var uriPattern = /^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$/i;
              if (!uriPattern.test(product_uri)) {
                throw "Invalid URI format: " + product_uri;
              }
              // Return the URI as a string
              return "Product URI: " + product_uri;
            }

    stdout: message
    outputs:
      echoed:
        outputBinding:
          glob: message
          loadContents: true
          outputEval: $(self[0].contents)
        type: string


  