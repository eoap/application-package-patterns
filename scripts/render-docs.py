"""Render current typed contracts and PlantUML sources for the twelve lessons."""
import importlib.util
from io import StringIO
import json
from pathlib import Path
from cwl_loader import load_cwl_from_location
from cwl2puml import to_puml, DiagramType
root = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('cwl_docs', root / 'scripts/cwl-docs.py')
contract = importlib.util.module_from_spec(spec)
spec.loader.exec_module(contract)
for n in range(1, 13):
    name = f'pattern-{n}'
    source = root / 'cwl-workflow' / f'{name}.cwl'
    processes = load_cwl_from_location(path=str(source))
    diagram_dir = root / 'docs' / name
    diagram_dir.mkdir(exist_ok=True)
    markdown = contract.render(source)
    markdown += '\n## Run the wrapped pattern\n\n'
    markdown += 'The application uses local File/Directory ports. `eoap-cwlwrap` converts these to typed URI references and composes mastering 2.0.0 staging, using immutable GHCR container digests. Configure `PATTERNS_S3_ENDPOINT` for your S3 service.\n\n'
    markdown += f'```bash\npython scripts/run-acceptance.py --case {name}\n```\n\n'
    markdown += 'The typed application inputs are:\n\n```json\n' + (root / 'cwl-workflow' / f'{name}-inputs.json').read_text().rstrip() + '\n```\n\n'
    markdown += 'The acceptance runner adds S3 credentials, bucket and a unique publication prefix. It verifies returned STAC links and georeferenced raster assets against the actual area of interest.\n\n## Diagrams\n\n'
    for kind in DiagramType:
        stream = StringIO()
        to_puml(cwl_document={p.id:p for p in processes}, diagram_type=kind, output_stream=stream)
        text = stream.getvalue()
        if '@enduml' not in text: text += '\n@enduml\n'
        filename = kind.name.lower()
        (diagram_dir / f'{filename}.puml').write_text('\n'.join(line.rstrip() for line in text.splitlines()).rstrip() + '\n')
        markdown += f'### {kind.name.replace("_", " ").title()}\n\n![{kind.name.title()} diagram]({name}/{filename}.svg)\n\n[PlantUML source]({name}/{filename}.puml)\n\n'
    (root / 'docs' / f'{name}.md').write_text(markdown.rstrip() + '\n')
    print(f'Rendered {name}', flush=True)
