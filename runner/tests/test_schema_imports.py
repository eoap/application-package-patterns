"""Ensure wrapping preserves published contracts in a standalone graph."""

import importlib.util
from pathlib import Path

import yaml


def test_graph_wrap_keeps_published_uri_import(tmp_path):
    root = Path(__file__).resolve().parents[2]
    spec = importlib.util.spec_from_file_location(
        "pattern_wrap_regression", root / "scripts/wrap-pattern.py"
    )
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    path = module.compose("pattern-12", tmp_path / "wrapped.cwl")
    document = yaml.safe_load(path.read_text())
    records = []

    def visit(value):
        if isinstance(value, dict):
            records.append(value)
            for child in value.values():
                visit(child)
        elif isinstance(value, list):
            for child in value:
                visit(child)

    visit(document)
    assert any(
        value.get("$import")
        == "https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml"
        for value in records
    )
    assert any(
        value.get("$import") == "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml"
        for value in records
    )
    assert not any(
        value.get("type") == "record" and str(value.get("name", "")).endswith("#URI")
        for value in records
    )
    assert not any(str(value.get("$import", "")).startswith("eoap-types") for value in records)


def test_custom_type_ports_retain_published_identifiers():
    from patterns.graph import load_document

    root = Path(__file__).resolve().parents[2]
    processes = load_document(root / "cwl-workflow/test-custom-types.cwl")
    assert isinstance(processes, list)
    workflow = next(process for process in processes if process.id.endswith("test-custom-types"))
    types = {port.id.rsplit("/", 1)[-1]: port.type_ for port in workflow.inputs}
    assert (
        types["start_time"]
        == "https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#DateTime"
    )
    assert (
        types["product_uri"]
        == "https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml#URI"
    )
    assert types["bbox"] == "https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml#BBox"
