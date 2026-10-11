# Changelog

## ## [0.3.1] - 2026-10-08

### Fixed

- Updated `cwl-workflow/test-custom-types.cwl` to CWL v1.2 so that imported lists of custom schema definitions load successfully with `cwl_utils` in Calrimate.
- Retained the required Schema.org application metadata, avoiding the missing-metadata validation errors seen in the published `test-custom-types:0.3.0` package.
- Corrected the user-manual URL to `https://eoap.github.io/application-package-patterns/`.

### Validation

- Successfully rendered a claim referencing the corrected local CWL with `cr.terradue.com/calrimate/calrimate:latest-dev`.
- Passed `cwltool --enable-ext --validate` for the source workflow.
- Successfully wrapped the workflow with `eoap-cwlwrap` 0.30.0 and validated the generated CWL using the deployment's stage-in and stage-out artifacts.
