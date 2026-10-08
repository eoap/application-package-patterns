# Pattern 4 - NDVI and NDWI vegetation indexes v1.0.0

* one input parameter of type `Directory`
* two output parameters of type `Directory`

This scenario takes as input an acquisition, applies two algorithms and generates two outputs.

Implementation: process the NDVI and NDWI taking as input a Landsat-8/9 acquisition. The output include two STAC Catalogs, each with a single STAC Item


> This software is licensed under the terms of the [Apache License 2.0](https://spdx.org/licenses/Apache-2.0.html) license - SPDX short identifier: [Apache-2.0](https://spdx.org/licenses/Apache-2.0)
>
> 2025-01-01 - 2026-08-28T13:26:06.102 Copyright [Make Earth Observation Great Again](mailto:info@meoga.com) - > [https://ror.org/9999cx000](https://ror.org/9999cx000)

## Project Team

### Authors

| Name | Email | Organization | Role | Identifier |
|------|-------|--------------|------|------------|
| Lane, Lois | [lois.lane@meoga.com](mailto:lois.lane@meoga.com) | [Make Earth Observation Great Again](https://ror.org/9999cx000) | [Project administration](https://credit.niso.org/contributor-roles/project-administration/) | [https://orcid.org/0000-9999-0000-9999](https://orcid.org/0000-9999-0000-9999) |
| Kent, Clark | [clark.kent@meoga.com](mailto:clark.kent@meoga.com) | [Make Earth Observation Great Again](https://ror.org/9999cx000) | [Supervision](https://credit.niso.org/contributor-roles/supervision/) | [https://orcid.org/9999-0000-9999-0000](https://orcid.org/9999-0000-9999-0000) |


### Contributors

| Name | Email | Organization | Role | Identifier |
|------|-------|--------------|------|------------|
| Luthor, Lex | [lex.luthor@meoga.com](mailto:lex.luthor@meoga.com) | [Make Earth Observation Great Again](https://ror.org/9999cx000) | [Software](https://credit.niso.org/contributor-roles/software/) | [None](None) |



## User Manual

User Manual can be found on [https://eoap.github.io/application-package-patterns/pattern-1/](https://eoap.github.io/application-package-patterns/pattern-1/).


## Runtime environment

### Supported Operating Systems

- Linux
- macOS
- macOS Server

### Requirements

- [https://cwltool.readthedocs.io/en/latest/](https://cwltool.readthedocs.io/en/latest/)
- [https://www.python.org/](https://www.python.org/)


---


## pattern-4

### CWL Class

[Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow)



### Inputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `aoi` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | area of interest | area of interest as a bounding box |
| `epsg` | [string](https://www.commonwl.org/v1.2/Workflow.html#CWLType) | EPSG code | EPSG code |
| `item` | [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | Landsat-8/9 acquisition reference | Landsat-8/9 acquisition reference |


### Steps

| Id | Runs | Label | Doc |
|----|------|-------|-----|
| [step](#clt) | `#clt` | Compute NDVI and NDWI | Compute NDVI and NDWI from Landsat-8/9 acquisitions |


### Outputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `ndvi` | [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | NDVI vegetation index | NDVI vegetation index |
| `ndwi` | [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | NDWI vegetation index | NDWI vegetation index |


### OGC API - Processes

When `pattern-4` [Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow) is exposed through [OGC API - Processes - Part 1: Core](https://docs.ogc.org/is/18-062r2/18-062r2.html), `inputs` and `outputs` fields below represent the interface of the [getProcessDescription](https://developer.ogc.org/api/processes/index.html#tag/ProcessDescription/operation/getProcessDescription) API. 



#### Inputs

![pattern-4 OGC API Processes JSON Inputs schema](./pattern-4/ogc_processes_inputs.svg "pattern-4  diagram")

#### Outputs

![pattern-4 OGC API Processes JSON Outputs schema](./pattern-4/ogc_processes_outputs.svg "pattern-4  diagram")


### UML Diagrams


#### Activity diagram

Learn more about the [Activity diagram](https://en.wikipedia.org/wiki/Activity_diagram) below.

![pattern-4 flow diagram](./pattern-4/activity.svg "pattern-4 Activity diagram")

#### Component diagram

Learn more about the [Component diagram](https://en.wikipedia.org/wiki/Component_diagram) below.

![pattern-4 flow diagram](./pattern-4/component.svg "pattern-4 Component diagram")

#### Class diagram

Learn more about the [Class diagram](https://en.wikipedia.org/wiki/Class_diagram) below.

![pattern-4 flow diagram](./pattern-4/class.svg "pattern-4 Class diagram")

#### Sequence diagram

Learn more about the [Sequence diagram](https://en.wikipedia.org/wiki/Sequence_diagram) below.

![pattern-4 flow diagram](./pattern-4/sequence.svg "pattern-4 Sequence diagram")

#### State diagram

Learn more about the [State diagram](https://en.wikipedia.org/wiki/State_diagram) below.

![pattern-4 flow diagram](./pattern-4/state.svg "pattern-4 State diagram")


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

### Execution usage example:

```
runner pattern-4 \
--input-item <ITEM> \
--aoi <AOI> \
--epsg <EPSG>
```

