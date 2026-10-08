# Pattern 5 - Water bodies detection based on NDWI and the otsu threshold v1.0.0

* one input parameter of type `Directory`
* scatter on an output parameter of type `Directory[]`

This scenario takes as input an acquisition, applies an algorithm and generates several outputs

Implementation: process the NDVI and NDWI taking as input a Landsat-8/9 acquisition and generating a stack of STAC Catalogs


> This software is licensed under the terms of the [Apache License 2.0](https://spdx.org/licenses/Apache-2.0.html) license - SPDX short identifier: [Apache-2.0](https://spdx.org/licenses/Apache-2.0)
>
> 2025-01-01 - 2026-08-28T13:26:18.851 Copyright [Make Earth Observation Great Again](mailto:info@meoga.com) - > [https://ror.org/9999cx000](https://ror.org/9999cx000)

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


## pattern-5

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
| `item` | [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | Landsat-8/9 acquisition reference | Landsat-8/9 acquisition reference |


### Steps

| Id | Runs | Label | Doc |
|----|------|-------|-----|
| [step](#clt) | `#clt` | Compute vegetation indexes | Compute NDVI and NDWI vegetation indexes from the Landsat-8/9 acquisition |


### Outputs

| Id | Type | Label | Doc |
|----|------|-------|-----|
| `vegetation_indexes` | `array` of [Directory](https://www.commonwl.org/v1.2/Workflow.html#Directory) | Vegetation indexes | Vegetation indexes from Landsat-8/9 acquisitions |


### OGC API - Processes

When `pattern-5` [Workflow](https://www.commonwl.org/v1.2/Workflow.html#Workflow) is exposed through [OGC API - Processes - Part 1: Core](https://docs.ogc.org/is/18-062r2/18-062r2.html), `inputs` and `outputs` fields below represent the interface of the [getProcessDescription](https://developer.ogc.org/api/processes/index.html#tag/ProcessDescription/operation/getProcessDescription) API. 



#### Inputs

![pattern-5 OGC API Processes JSON Inputs schema](./pattern-5/ogc_processes_inputs.svg "pattern-5  diagram")

#### Outputs

![pattern-5 OGC API Processes JSON Outputs schema](./pattern-5/ogc_processes_outputs.svg "pattern-5  diagram")


### UML Diagrams


#### Activity diagram

Learn more about the [Activity diagram](https://en.wikipedia.org/wiki/Activity_diagram) below.

![pattern-5 flow diagram](./pattern-5/activity.svg "pattern-5 Activity diagram")

#### Component diagram

Learn more about the [Component diagram](https://en.wikipedia.org/wiki/Component_diagram) below.

![pattern-5 flow diagram](./pattern-5/component.svg "pattern-5 Component diagram")

#### Class diagram

Learn more about the [Class diagram](https://en.wikipedia.org/wiki/Class_diagram) below.

![pattern-5 flow diagram](./pattern-5/class.svg "pattern-5 Class diagram")

#### Sequence diagram

Learn more about the [Sequence diagram](https://en.wikipedia.org/wiki/Sequence_diagram) below.

![pattern-5 flow diagram](./pattern-5/sequence.svg "pattern-5 Sequence diagram")

#### State diagram

Learn more about the [State diagram](https://en.wikipedia.org/wiki/State_diagram) below.

![pattern-5 flow diagram](./pattern-5/state.svg "pattern-5 State diagram")


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

