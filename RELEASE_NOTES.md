# Application Package Patterns 2.0.0

The twelve patterns now expose typed CWL v1.2 contracts with embedded custom definitions. eoap-cwlwrap 0.32.0 composes standalone workflows using the mastering 2.0.1-rc.44.1 stage-in and stage-out commands and immutable GHCR container digests. Directory staging no longer injects copies of Python staging scripts.

Real Landsat processing and S3 publication are checked across all twelve patterns and four optional-port cases. Acceptance validates metadata and standalone CWL, verifies returned STAC links and raster assets on authenticated S3, and builds the static Markdown documentation strictly. Dependencies are hash-locked for Python 3.12; AMD64 is the acceptance architecture.

Release artifacts include original and wrapped CWL, typed jobs, staging adapters with source provenance, the Python lock and checksums. Standalone and wrapped packages are published to GHCR after acceptance. The existing patterns runner image is consumed by immutable digest; no runtime dependency upgrade is claimed. This release changes the earlier primitive input contract.
