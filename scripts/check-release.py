"""Check typed release contracts, immutable images and staging provenance."""
import json
from pathlib import Path
import re
import yaml
root = Path(__file__).resolve().parents[1]
version = json.loads((root / 'codemeta.json').read_text())['version']
assert re.fullmatch(r'\d+\.\d+\.\d+', version)
lock = json.loads((root / 'mastering-staging.lock.json').read_text())
files = sorted((root / 'cwl-workflow').glob('*.cwl')) + sorted((root / 'templates').glob('*.cwl'))
assert len(files) == 17
for path in files:
    document = yaml.safe_load(path.read_text())
    assert document['cwlVersion'] == 'v1.2', path
    expected = lock['version'] if path.parent.name == 'templates' and path.stem in lock['sources'] else version
    assert document['s:softwareVersion'] == expected, path
    def check(value):
        if isinstance(value, dict):
            if 'dockerPull' in value: assert re.search(r'@sha256:[a-f0-9]{64}$', value['dockerPull']), value['dockerPull']
            for child in value.values(): check(child)
        elif isinstance(value, list):
            for child in value: check(child)
    check(document)
for name, source in lock['sources'].items():
    document = yaml.safe_load((root / 'templates' / f'{name}.cwl').read_text())
    assert document['requirements']['DockerRequirement']['dockerPull'] == source['image']
    assert document['s:isBasedOn'] == source['url']
    assert document['baseCommand'] == name
assert len(list((root / 'cwl-workflow').glob('pattern-*-inputs.json'))) == 12
print(f'{len(files)} typed release documents, twelve jobs and mastering {lock["version"]} staging verified')
