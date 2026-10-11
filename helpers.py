import sys
import graphviz
from cwl2puml import to_puml, DiagramType
from cwltool.main import main as cwlmain
from cwltool.context import LoadingContext, RuntimeContext
from cwltool.executors import NoopJobExecutor
from io import StringIO, BytesIO
from IPython.display import Markdown, display
from eoap_cwlwrap import wrap
def type_to_string(value):
    return str(value)
from cwl_loader import load_cwl_from_location
from cwl_loader.utils import search_process
from PIL import Image
from plantuml import deflate_and_encode
from urllib.request import urlopen
import cwl_loader
cwl_loader.logger.remove()
cwl_loader.logger.add(sys.stderr, level="INFO")

import eoap_cwlwrap
eoap_cwlwrap.logger.remove()
#eoap_cwlwrap.logger.add(sys.stderr, level="INFO")

class WorkflowViewer:
    def __init__(self, cwl_file, workflow, entrypoint):
        self.cwl_file = cwl_file
        self.workflow = workflow
        self.entrypoint = entrypoint
        self.output = ".wrapped.cwl"
        self.base_url = "https://raw.githubusercontent.com/eoap/application-package-patterns/refs/heads/main"

    @staticmethod
    def from_file(cwl_file, entrypoint):
        workflow = load_cwl_from_location(path=cwl_file)
        return WorkflowViewer(cwl_file, workflow, entrypoint)

    @staticmethod
    def from_reference(cwl_file, workflow, entrypoint):
        return WorkflowViewer(cwl_file, workflow, entrypoint)

    def _prepare_headers(self, headers: list[str]):
        return f"| {' | '.join(headers)} |\n| {' | '.join(["---"] * len(headers))} |\n"

    def _display_parameters(self, parameters_name):
        md = self._prepare_headers(["Id", "Type", "Label", "Doc"])

        wf = search_process(process_id=self.entrypoint, process=self.workflow)

        for p in getattr(wf, parameters_name, []):
            md += f"| `{p.id}` | `{type_to_string(p.type_)}` | {p.label} | {p.doc} |\n"

        display(Markdown(md))

    def display_inputs(self):
        self._display_parameters("inputs")

    def display_outputs(self):
        self._display_parameters("outputs")

    def display_steps(self):
        md = self._prepare_headers(["Id", "Runs", "Label", "Doc"])

        for step in search_process(
            process_id=self.entrypoint, process=self.workflow
        ).steps:
            md += f"| `{step.id.replace(f'file:///#{self.entrypoint}/', '')}` | `{step.run}` | {step.label} | {step.doc} |\n"

        display(Markdown(md))

    def display_components_diagram(self):
        out = StringIO()
        to_puml(
            cwl_document={process.id: process for process in (self.workflow if isinstance(self.workflow, list) else [self.workflow])},
            diagram_type=DiagramType.COMPONENT,
            output_stream=out,
        )

        display(Markdown("```plantuml\n" + out.getvalue() + "\n```"))
        display(self.plot())

    def plot(self):
        args = ["--print-dot", f"{self.cwl_file}#{self.entrypoint}"]

        stream_err = StringIO()
        stream_out = StringIO()

        _ = cwlmain(
            args,
            stdout=stream_out,
            stderr=stream_err,
            executor=NoopJobExecutor(),
            loadingContext=LoadingContext(),
            runtimeContext=RuntimeContext(),
        )

        return graphviz.Source(stream_out.getvalue().replace("shape=record", "shape=box"))


class WorkflowWrapper:
    def __init__(self, workflow, entrypoint):
        self.workflow = workflow
        self.entrypoint = entrypoint
        self.base_url = "https://raw.githubusercontent.com/eoap/application-package-patterns/refs/heads/feature/pde-typed-cwl"

    def wrap(self):
        from pathlib import Path
        templates = Path(__file__).resolve().parents[1] / "templates"
        directory_stage_in = load_cwl_from_location(path=str(templates / "stage-in.cwl"))
        file_stage_in = load_cwl_from_location(path=str(templates / "stage-in-file.cwl"))
        directory_stage_out = load_cwl_from_location(path=str(templates / "stage-out.cwl"))
        workflow = search_process(process_id=self.entrypoint, process=self.workflow)
        main = wrap(
            workflow=workflow,
            directory_stage_in=directory_stage_in,
            file_stage_in=file_stage_in,
            directory_stage_out=directory_stage_out,
        )
        application = self.workflow if isinstance(self.workflow, list) else [self.workflow]
        return [main, *application, directory_stage_in, file_stage_in, directory_stage_out]


def embed_wrapper_types(path, application=None):
    """Embed the wrapper-introduced URI definition after dump_cwl serialization."""
    from copy import deepcopy
    from pathlib import Path
    import yaml
    template = yaml.safe_load((Path(__file__).resolve().parents[1] / "templates/stage-out.cwl").read_text())
    schemas = template["requirements"]["SchemaDefRequirement"]["types"]
    def embed(value):
        if isinstance(value, dict):
            if value.get("$import") == "https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml":
                return deepcopy(schemas)
            return {key: embed(child) for key, child in value.items()}
        if isinstance(value, list):
            result = []
            for child in value:
                entry = embed(child)
                result.extend(entry) if isinstance(entry, list) else result.append(entry)
            return result
        return value
    target = Path(path)
    document = embed(yaml.safe_load(target.read_text()))
    # Relocate embedded module type identifiers into this standalone document.
    # DOM serialization preserves the original checkout URI in type names.
    local_documents = set()
    def collect(value):
        if isinstance(value, dict):
            name = value.get("name", "")
            if isinstance(name, str) and name.startswith("file://") and "#" in name and value.get("type") in ("record", "enum"):
                local_documents.add(name.split("#", 1)[0])
            for child in value.values(): collect(child)
        elif isinstance(value, list):
            for child in value: collect(child)
    collect(document)
    def relocate(value):
        if isinstance(value, str) and "#" in value and value.split("#", 1)[0] in local_documents:
            return "#" + value.split("#", 1)[1]
        if isinstance(value, dict):
            # Anonymous array names introduce a separate URI scope for local types.
            anonymous_array = value.get("type") == "array" and str(value.get("name", "")).startswith("_:")
            return {key: relocate(child) for key, child in value.items() if not (anonymous_array and key == "name")}
        if isinstance(value, list): return [relocate(child) for child in value]
        return value
    document = relocate(document)
    # Keep the approved shared schema imports in their original form.
    # Serializing them as remote-named inline types confuses schema loaders.
    approved = ("https://raw.githubusercontent.com/eoap/schemas/main/ogc.yaml",
                "https://raw.githubusercontent.com/eoap/schemas/main/geojson.yaml")
    def restore_imports(value):
        if isinstance(value, dict):
            if "types" in value and isinstance(value["types"], list):
                result = []
                imported = set()
                for schema in value["types"]:
                    name = schema.get("name", "") if isinstance(schema, dict) else ""
                    url = next((url for url in approved if name.startswith(url + "#")), None)
                    if url:
                        if url not in imported: result.append({"$import": url}); imported.add(url)
                    else: result.append(schema)
                value["types"] = result
            for child in value.values(): restore_imports(child)
        elif isinstance(value, list):
            for child in value: restore_imports(child)
    restore_imports(document)
    def unique_inputs(value):
        if isinstance(value, dict):
            inputs = value.get("inputs")
            if isinstance(inputs, list):
                unique = {}
                for port in inputs:
                    identifier = port["id"]
                    if identifier in unique and unique[identifier] != port:
                        raise ValueError(f"Conflicting duplicate input: {identifier}")
                    unique[identifier] = port
                value["inputs"] = list(unique.values())
            for child in value.values(): unique_inputs(child)
        elif isinstance(value, list):
            for child in value: unique_inputs(child)
    unique_inputs(document)
    metadata = yaml.safe_load(Path(application).read_text()) if application else template
    for key, value in metadata.items():
        if key.startswith("s:") or key == "$namespaces": document[key] = deepcopy(value)
    target.write_text(yaml.safe_dump(document, sort_keys=False))
