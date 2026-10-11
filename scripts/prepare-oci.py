"""Derive and verify portable OCI metadata for every accepted release workflow."""
import argparse
import json
from pathlib import Path
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--source-dir', type=Path, required=True)
parser.add_argument('--wrapped-dir', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
parser.add_argument('--revision', required=True)
parser.add_argument('--version', required=True)
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
files = [(p, p.stem, p.stem) for p in sorted(args.source_dir.glob('*.cwl'))]
files += [(p, p.stem + '-wrapped', 'main') for p in sorted(args.wrapped_dir.glob('*.cwl'))]
assert len(files) == 26, 'Expected fourteen source workflows and twelve wrappers'
for path, name, entrypoint in files:
    output = args.output / f'{name}.annotations.json'
    subprocess.run(['transpiler-mate', 'cwl2oci', '--image-source',
        'https://github.com/eoap/application-package-patterns', '--image-revision',
        args.revision, '--output', str(output), f'{path}#{entrypoint}'], check=True)
    document = json.loads(output.read_text())
    annotations = document['$manifest']
    for key in ('org.opencontainers.image.title', 'org.opencontainers.image.description',
                'org.opencontainers.image.licenses', 'org.opencontainers.image.source',
                'org.opencontainers.image.revision', 'org.cwl.entrypoint'):
        assert isinstance(annotations.get(key), str) and annotations[key], (name, key)
    assert annotations['org.opencontainers.image.version'] == args.version
    assert annotations['org.cwl.spec'] == 'v1.2'
    assert annotations['org.cwl.type'] == 'Workflow'
    assert annotations['org.cwl.entrypoint'].split('#')[-1] == entrypoint
    annotations['org.cwl.entrypoint'] = f'{path.name}#{entrypoint}'
    output.write_text(json.dumps(document, indent=2) + '\n')
print(f'Validated portable OCI metadata for {len(files)} artifacts')
