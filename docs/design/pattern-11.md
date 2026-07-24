# Water bodies detection based on NDWI and the otsu threshold (with DEM) v1.0.0

Water bodies detection based on NDWI and otsu threshold applied to a single Landsat-8/9 acquisition.

> This software is licensed under the terms of the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) license - SPDX short identifier: [Apache-2.0](https://spdx.org/licenses/Apache-2.0)
>
> 2025-01-01 - 2026-07-24T17:28:03.395 Copyright [Make Earth Observation Great Again](mailto:info@meoga.com) - > [https://ror.org/9999cx000](https://ror.org/9999cx000)

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


## pattern-11

### CWL Class

[Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow)



### Inputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `aoi` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | area of interest | area of interest as a bounding box |
| `epsg` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | EPSG code | EPSG code |
| `bands` | `array` of [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | bands used for the NDWI | bands used for the NDWI |
| `item` | [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | Landsat-8/9 acquisition reference | Landsat-8/9 acquisition reference |
| `dem` | [File](https://www.commonwl.org/v1.2/Workflow.html#File) | Digital Elevation Model (DEM) | Digital Elevation Model (DEM) geotiff |


### Steps

| Id | Runs | Label | Doc |
|----|------|-------|-----|
| [step](#clt) | `#clt` | Detect water bodies | Detect water bodies based on the NDWI and otsu threshold from Landsat-8/9 acquisition and DEM |


### Outputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `water_bodies` | [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | Water bodies detected | Water bodies detected based on the NDWI and otsu threshold |


### OGC API - Processes

When `pattern-11` [Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow) is exposed through [OGC API - Processes - Part 1: Core](https://docs.ogc.org/is/18-062r2/18-062r2.html), `inputs` and `outputs` fields below represent the interface of the [getProcessDescription](https://developer.ogc.org/api/processes/index.html#tag/ProcessDescription/operation/getProcessDescription) API. 



#### Inputs

![pattern-11 OGC API Processes JSON Inputs schema](./pattern-11/ogc_processes_inputs.svg "pattern-11  diagram")

#### Outputs

![pattern-11 OGC API Processes JSON Outputs schema](./pattern-11/ogc_processes_outputs.svg "pattern-11  diagram")


### UML Diagrams


#### Activity diagram

Learn more about the [Activity diagram](https://en.wikipedia.org/wiki/Activity_diagram) below.

![pattern-11 flow diagram](./pattern-11/activity.svg "pattern-11 Activity diagram")

#### Component diagram

Learn more about the [Component diagram](https://en.wikipedia.org/wiki/Component_diagram) below.

![pattern-11 flow diagram](./pattern-11/component.svg "pattern-11 Component diagram")

#### Class diagram

Learn more about the [Class diagram](https://en.wikipedia.org/wiki/Class_diagram) below.

![pattern-11 flow diagram](./pattern-11/class.svg "pattern-11 Class diagram")

#### Sequence diagram

Learn more about the [Sequence diagram](https://en.wikipedia.org/wiki/Sequence_diagram) below.

![pattern-11 flow diagram](./pattern-11/sequence.svg "pattern-11 Sequence diagram")

#### State diagram

Learn more about the [State diagram](https://en.wikipedia.org/wiki/State_diagram) below.

![pattern-11 flow diagram](./pattern-11/state.svg "pattern-11 State diagram")


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
| `band` | `--band` | One of:<ul><li>`array` of [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType)</li></ul> |
| `dem` | `--dem` | [File](https://www.commonwl.org/v1.2/Workflow.html#File) |

### Execution usage example:

```
runner pattern-11 \
--input-item <ITEM> \
--aoi <AOI> \
--epsg <EPSG> \
--band <BAND> \
--dem <DEM>
```

