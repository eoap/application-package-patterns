"""Compose a standalone pattern with mastering staging using eoap-cwlwrap."""
import argparse
from pathlib import Path
import sys
from cwl_loader import dump_cwl

root = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(root / 'docs'))
from helpers import WorkflowViewer, WorkflowWrapper, embed_wrapper_types


def compose(name, output):
    source = root / 'cwl-workflow' / f'{name}.cwl'
    workflow = WorkflowViewer.from_file(str(source), name)
    wrapped = WorkflowWrapper(workflow.workflow, name).wrap()
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open('w') as stream:
        dump_cwl(process=wrapped, stream=stream)
    embed_wrapper_types(output, source)
    return output


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pattern', choices=[f'pattern-{n}' for n in range(1, 13)])
    parser.add_argument('--output', type=Path, default=root / 'wrapped-cwl-workflow')
    args = parser.parse_args()
    names = [args.pattern] if args.pattern else [f'pattern-{n}' for n in range(1, 13)]
    for name in names:
        print(compose(name, args.output / f'{name}.cwl'))
