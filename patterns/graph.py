"""Load validated multi-process documents through the public CWL SDKs."""

from collections.abc import Mapping
from pathlib import Path

from cwl_loader import load_cwl_from_yaml
from cwl_utils.parser import Process
from cwl_utils.parser.cwl_v1_2 import (
    CommandInputArraySchema,
    CommandOutputArraySchema,
    InputArraySchema,
    OutputArraySchema,
)
from cwltool.context import LoadingContext
from cwltool.load_tool import fetch_document, resolve_and_validate_document

SCHEMA_ALIASES = {
    "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#": "#_shared_ogc_",
    "https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#": "#_shared_string_format_",
    "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml#": "#_shared_geojson_",
}


def _scope_shared_names(value: object) -> object:
    """Give imported SDK types separate in-memory names without changing source."""
    if isinstance(value, str):
        for namespace, alias in SCHEMA_ALIASES.items():
            if value.startswith(namespace):
                return alias + value[len(namespace) :]
    elif isinstance(value, dict):
        return {key: _scope_shared_names(child) for key, child in value.items()}
    elif isinstance(value, list):
        return [_scope_shared_names(child) for child in value]
    return value


def load_document(path: Path) -> Process | list[Process]:
    """Validate and resolve imports, then parse the graph into CWL SDK models.

    CWL Utils cannot parse imported schema arrays in a raw graph. cwltool's
    public loader resolves and validates them first. Temporary names avoid
    collisions with course-owned BBox/CRS types; export restores the original
    published schema imports. No packing or validation bypass is involved.
    """
    context = LoadingContext()
    context.do_update = False
    context, document, uri = fetch_document(str(path), context)
    context, uri = resolve_and_validate_document(context, document, uri)
    if context.loader is None:
        raise ValueError("CWL SDK did not initialize its document loader")
    processes, metadata = context.loader.resolve_ref(uri)
    payload = dict(metadata)
    payload["cwlVersion"] = "v1.2"
    if isinstance(processes, list):
        payload["$graph"] = processes
    elif isinstance(processes, Mapping):
        payload.update(processes)
    else:
        raise ValueError("CWL SDK did not return a process mapping or graph")
    scoped = _scope_shared_names(payload)
    if not isinstance(scoped, dict):
        raise ValueError("CWL graph metadata must be a mapping")
    result = load_cwl_from_yaml(scoped, uri=path.resolve().as_uri())
    _restore_shared_ports(result if isinstance(result, list) else [result])
    return result


def _published_type(reference: str) -> str:
    """Expose the original published identifier after temporary SDK scoping."""
    fragment = "#" + reference.rsplit("#", 1)[-1] if "#" in reference else reference
    for namespace, alias in SCHEMA_ALIASES.items():
        if fragment.startswith(alias):
            return namespace + fragment[len(alias) :]
    return reference


def _restore_shared_ports(processes: list[Process]) -> None:
    """Restore published type identifiers for wrapping and lesson displays."""
    for process in processes:
        for port in [*process.inputs, *process.outputs]:
            if isinstance(port.type_, str):
                port.type_ = _published_type(port.type_)
            elif isinstance(port.type_, list):
                port.type_ = [_published_type(t) if isinstance(t, str) else t for t in port.type_]
            elif isinstance(
                port.type_,
                (
                    InputArraySchema,
                    OutputArraySchema,
                    CommandInputArraySchema,
                    CommandOutputArraySchema,
                ),
            ) and isinstance(port.type_.items, str):
                port.type_.items = _published_type(port.type_.items)
