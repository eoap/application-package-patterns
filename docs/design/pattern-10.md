# NDVI and NDWI vegetation indexes v1.0.0

NDVI and NDWI vegetation indexes from Landsat-8/9 acquisitions.

> This software is licensed under the terms of the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) license - SPDX short identifier: [Apache-2.0](https://spdx.org/licenses/Apache-2.0)
>
> 2025-01-01 - 2026-07-24T17:27:51.268 Copyright [Make Earth Observation Great Again](mailto:info@meoga.com) - > [https://ror.org/9999cx000](https://ror.org/9999cx000)

## Project Team

### Authors

| Name | Email | Organization | Role | Identifier |
|------|-------|--------------|------|------------|
| Lane, Lois | [lois.lane@dailyplanet.com](mailto:lois.lane@dailyplanet.com) | [Daily Planet](https://ror.org/0000cx000) | [Project Manager](http://purl.org/spar/datacite/ProjectManager) | [https://orcid.org/0000-9999-0000-9999](https://orcid.org/0000-9999-0000-9999) |
| Kent, Clark | [clark.kent@dailyplanet.com](mailto:clark.kent@dailyplanet.com) | [Daily Planet](https://ror.org/0000cx000) | [Researcher](http://purl.org/spar/datacite/Researcher) | [https://orcid.org/0000-9999-0000-9999](https://orcid.org/0000-9999-0000-9999) |


### Contributors

| Name | Email | Organization | Role | Identifier |
|------|-------|--------------|------|------------|
| Luthor, Lex | [lex.luthor@luthorcorp.com](mailto:lex.luthor@luthorcorp.com) | [Luthor Corp](https://ror.org/0000cx000) | []() | [https://orcid.org/0000-9999-0000-9999](https://orcid.org/0000-9999-0000-9999) |



## User Manual

User Manual can be found on [https://eoap.github.io/application-package-patterns/](https://eoap.github.io/application-package-patterns/).


## Runtime environment

### Supported Operating Systems

- Linux
- macOS

### Requirements

- [https://cwltool.readthedocs.io/en/latest/](https://cwltool.readthedocs.io/en/latest/)
- [https://www.python.org/](https://www.python.org/)


## Software Source code

- Browsable version of the [source repository](https://github.com/eoap/application-package-patterns.git);
- [Continuous integration](https://github.com/eoap/application-package-patterns/actions) system used by the project;
- Issues, bugs, and feature requests should be submitted to the following [issue management](https://github.com/eoap/application-package-patterns/issues) system for this project


---


## pattern-10

### CWL Class

[Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow)

### Requirements

* [SubworkflowFeatureRequirement](https://www.commonwl.org/v1.2/Workflow.html#SubworkflowFeatureRequirement)
* [ScatterFeatureRequirement](https://www.commonwl.org/v1.2/Workflow.html#ScatterFeatureRequirement)

### Inputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `aoi` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | area of interest | area of interest as a bounding box |
| `epsg` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | EPSG code | EPSG code |
| `indexes` | `array` of [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | indexes | indexes to compute |
| `items` | `array` of [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | Landsat-8/9 acquisition reference | Landsat-8/9 acquisition reference |


### Steps

| Id | Runs | Label | Doc |
|----|------|-------|-----|
| [subworkflow](#vegetation_indexes) | `#vegetation_indexes` | Compute vegetation indexes | Compute NDVI and NDWI vegetation indexes from the Landsat-8/9 acquisitions |
| [flatten](#flatten_array) | `#flatten_array` | Flatten Directory[][] → Directory[] | Flatten the nested array of Directories into a single array |


### Outputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `vegetation_indexes` | `array` of [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | Vegetation indexes | Vegetation indexes from Landsat-8/9 acquisitions |


### OGC API - Processes

When `pattern-10` [Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow) is exposed through [OGC API - Processes - Part 1: Core](https://docs.ogc.org/is/18-062r2/18-062r2.html), `inputs` and `outputs` fields below represent the interface of the [getProcessDescription](https://developer.ogc.org/api/processes/index.html#tag/ProcessDescription/operation/getProcessDescription) API. 



#### Inputs

![pattern-10 OGC API Processes JSON Inputs schema](./pattern-10/ogc_processes_inputs.svg "pattern-10  diagram")

#### Outputs

![pattern-10 OGC API Processes JSON Outputs schema](./pattern-10/ogc_processes_outputs.svg "pattern-10  diagram")


### UML Diagrams


#### Activity diagram

Learn more about the [Activity diagram](https://en.wikipedia.org/wiki/Activity_diagram) below.

![pattern-10 flow diagram](./pattern-10/activity.svg "pattern-10 Activity diagram")

#### Component diagram

Learn more about the [Component diagram](https://en.wikipedia.org/wiki/Component_diagram) below.

![pattern-10 flow diagram](./pattern-10/component.svg "pattern-10 Component diagram")

#### Class diagram

Learn more about the [Class diagram](https://en.wikipedia.org/wiki/Class_diagram) below.

![pattern-10 flow diagram](./pattern-10/class.svg "pattern-10 Class diagram")

#### Sequence diagram

Learn more about the [Sequence diagram](https://en.wikipedia.org/wiki/Sequence_diagram) below.

![pattern-10 flow diagram](./pattern-10/sequence.svg "pattern-10 Sequence diagram")

#### State diagram

Learn more about the [State diagram](https://en.wikipedia.org/wiki/State_diagram) below.

![pattern-10 flow diagram](./pattern-10/state.svg "pattern-10 State diagram")


### Run in step

`subworkflow`



## vegetation_indexes

### CWL Class

[Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow)

### Requirements

* [ScatterFeatureRequirement](https://www.commonwl.org/v1.2/Workflow.html#ScatterFeatureRequirement)

### Inputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `aoi` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | area of interest | area of interest as a bounding box |
| `epsg` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | EPSG code | EPSG code |
| `indexes` | `array` of [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | indexes | indexes to compute |
| `item` | [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | STAC item reference | Reference to a STAC item |


### Steps

| Id | Runs | Label | Doc |
|----|------|-------|-----|
| [step](#clt) | `#clt` | None | None |


### Outputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `vegetation_indexes` | `array` of [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | Vegetation indexes | Vegetation indexes |


### OGC API - Processes

When `vegetation_indexes` [Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow) is exposed through [OGC API - Processes - Part 1: Core](https://docs.ogc.org/is/18-062r2/18-062r2.html), `inputs` and `outputs` fields below represent the interface of the [getProcessDescription](https://developer.ogc.org/api/processes/index.html#tag/ProcessDescription/operation/getProcessDescription) API. 



#### Inputs

![vegetation_indexes OGC API Processes JSON Inputs schema](./vegetation_indexes/ogc_processes_inputs.svg "vegetation_indexes  diagram")

#### Outputs

![vegetation_indexes OGC API Processes JSON Outputs schema](./vegetation_indexes/ogc_processes_outputs.svg "vegetation_indexes  diagram")


### UML Diagrams


#### Activity diagram

Learn more about the [Activity diagram](https://en.wikipedia.org/wiki/Activity_diagram) below.

![vegetation_indexes flow diagram](./vegetation_indexes/activity.svg "vegetation_indexes Activity diagram")

#### Component diagram

Learn more about the [Component diagram](https://en.wikipedia.org/wiki/Component_diagram) below.

![vegetation_indexes flow diagram](./vegetation_indexes/component.svg "vegetation_indexes Component diagram")

#### Class diagram

Learn more about the [Class diagram](https://en.wikipedia.org/wiki/Class_diagram) below.

![vegetation_indexes flow diagram](./vegetation_indexes/class.svg "vegetation_indexes Class diagram")

#### Sequence diagram

Learn more about the [Sequence diagram](https://en.wikipedia.org/wiki/Sequence_diagram) below.

![vegetation_indexes flow diagram](./vegetation_indexes/sequence.svg "vegetation_indexes Sequence diagram")

#### State diagram

Learn more about the [State diagram](https://en.wikipedia.org/wiki/State_diagram) below.

![vegetation_indexes flow diagram](./vegetation_indexes/state.svg "vegetation_indexes State diagram")


### Run in step

`step`



## clt

### CWL Class

[CommandLineTool](https://www.commonwl.org/v1.2/CommandLineTool.html#CommandLineTool)

### Inputs

| Id | Option | Type |
|----|------|-------|
| `item` | `--input-item` | [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) |
| `aoi` | `--aoi` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) |
| `epsg` | `--epsg` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) |
| `index` | `--vegetation-index` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) |

### Execution usage example:

```
runner pattern-5 \
--input-item <ITEM> \
--aoi <AOI> \
--epsg <EPSG> \
--vegetation-index <INDEX>
```



### Run in step

`flatten`



## flatten_array

### CWL Class

[ExpressionTool](https://www.commonwl.org/v1.2/Workflow.html#ExpressionTool)

### Inputs

| Id | Option | Type |
|----|------|-------|
| `nested` | `--nested` | `array` of `array` of [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) |



