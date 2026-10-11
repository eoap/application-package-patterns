cwlVersion: v1.2
$namespaces:
  s: https://schema.org/
s:name: Stage-out STAC results
s:description: Upload the results catalog and its assets to S3-compatible storage.
s:dateCreated: '2022-09-01'
s:license:
  s:name: Creative Commons Attribution-ShareAlike 4.0 International
  s:url: https://creativecommons.org/licenses/by-sa/4.0/
  s:identifier: CC-BY-SA-4.0
s:softwareHelp:
  s:name: Mastering Earth Observation Application Packaging with CWL
  s:url: https://eoap.github.io/mastering-app-package
s:publisher:
  s:name: EO Application Packaging
  s:identifier: https://github.com/eoap
s:author:
- s:givenName: Jane
  s:familyName: Doe
  s:email: jane.doe@acme.earth
  s:affiliation:
    s:name: ACME
- s:givenName: John
  s:familyName: Doe
  s:email: john.doe@acme.earth
  s:affiliation:
    s:name: ACME
s:softwareRequirements:
- container runtime
- cwl runner
s:softwareVersion: 2.0.1-rc.44.1
class: CommandLineTool
id: stage-out
doc: Upload the results catalog and its assets to S3-compatible storage.
inputs:
  s3_bucket:
    type: string
    label: S3 bucket
    doc: Name of the destination S3 bucket.
  sub_path:
    type: string
    label: Object prefix
    doc: Object key prefix under which results are uploaded.
  aws_access_key_id:
    type: string
    label: S3 access key ID
    doc: Access key ID used to authenticate to the S3-compatible service.
  aws_secret_access_key:
    type: string
    label: S3 secret access key
    doc: Secret access key used to authenticate to the S3-compatible service.
  region_name:
    type: string
    label: S3 region
    doc: Region name used for S3 requests.
  endpoint_url:
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    label: S3 endpoint
    doc: URL of the S3-compatible service endpoint.
  stac_catalog:
    type: Directory
    label: Results STAC catalog
    doc: Directory containing the results STAC catalog and its referenced raster assets.
outputs:
  s3_catalog_output:
    outputBinding:
      outputEval: '${ return {value: "s3://" + inputs.s3_bucket + "/" + inputs.sub_path
        + "/" + inputs.stac_catalog.location.replace(/\/$/, "").split("/").slice(-2).join("-")
        + "/catalog.json"}; }'
    type: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
    label: Uploaded STAC catalog
    doc: S3 URI of the uploaded results catalog.
baseCommand: stage-out
arguments:
- $( inputs.stac_catalog.path )
- $( inputs.s3_bucket )
- $( inputs.sub_path + "/" + inputs.stac_catalog.location.replace(/\/$/, "").split("/").slice(-2).join("-")
  )
requirements:
  DockerRequirement:
    dockerPull: ghcr.io/eoap/mastering-app-package/stage-out@sha256:4e2c44b34f0d79ad380dca50913dc76c5be2448add86f992b872735581b6587a
  InlineJavascriptRequirement: {}
  NetworkAccess:
    networkAccess: true
  EnvVarRequirement:
    envDef:
      aws_access_key_id: $( inputs.aws_access_key_id )
      aws_secret_access_key: $( inputs.aws_secret_access_key )
      aws_region_name: $( inputs.region_name )
      aws_endpoint_url: $(inputs.endpoint_url.value)
      PATH: /app/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
  ResourceRequirement:
    coresMin: 1
    ramMin: 1024
    coresMax: 1
    ramMax: 1024
  SchemaDefRequirement:
    types:
    - type: record
      name: https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI
      doc: Represents a valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
      fields:
      - name: value
        type: string
        doc: A valid [URI](https://datatracker.ietf.org/doc/html/rfc3986).
  WorkReuse:
    enableReuse: false
  LoadListingRequirement:
    loadListing: deep_listing
label: Stage-out STAC results
s:codeRepository: https://github.com/eoap/mastering-app-package.git
s:isBasedOn: ghcr.io/eoap/mastering-app-package/cwl/stage-out@sha256:18c9e45c705d9b5c3d3cf91fc258f2d39dc184a6996edbdd76bb21d2405aa73a
