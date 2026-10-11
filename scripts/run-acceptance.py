"""Execute all wrapped patterns against real EO imagery and verify S3 outputs."""
import argparse
from copy import deepcopy
from datetime import datetime, timezone
import importlib.util
import json
import os
from pathlib import Path
import posixpath
import subprocess
from urllib.parse import urlparse
import boto3
import rasterio
from rasterio.io import MemoryFile
from rasterio.warp import transform_bounds

root = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('pattern_wrap', root / 'scripts/wrap-pattern.py')
wrapping = importlib.util.module_from_spec(spec)
spec.loader.exec_module(wrapping)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--runner', choices=['calrissian', 'cwltool'], default='calrissian')
parser.add_argument('--output', type=Path, default=Path('/calrissian/patterns'))
parser.add_argument('--case')
parser.add_argument('--endpoint', default=os.environ.get('PATTERNS_S3_ENDPOINT', 'http://eoap-application-package-patterns-s3-seaweedfs-all-in-one:8333'))
parser.add_argument('--bucket', default=os.environ.get('PATTERNS_S3_BUCKET', 'results'))
args = parser.parse_args()
stamp = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
evidence = args.output / stamp
evidence.mkdir(parents=True)
client = boto3.client('s3', endpoint_url=args.endpoint, region_name='us-east-1', aws_access_key_id=os.environ.get('AWS_ACCESS_KEY_ID', 'test'), aws_secret_access_key=os.environ.get('AWS_SECRET_ACCESS_KEY', 'test'))
client.head_bucket(Bucket=args.bucket)
cases = [(f'pattern-{n}', f'pattern-{n}', {}) for n in range(1, 13)]
cases += [('pattern-7-optional-unset', 'pattern-7', {'item_2':None}), ('pattern-8-output-unset', 'pattern-8', {'produce_output':False}), ('pattern-9-all-unset', 'pattern-9', {'indexes':['none','none']}), ('pattern-9-all-set', 'pattern-9', {'indexes':['ndvi','ndwi']})]
summary = []

def uris(value):
    if isinstance(value, dict):
        if isinstance(value.get('value'), str) and value['value'].startswith('s3://'): yield value['value']
        else:
            for child in value.values(): yield from uris(child)
    elif isinstance(value, list):
        for child in value: yield from uris(child)

def resolve(base, href):
    if urlparse(href).scheme: return href
    parsed = urlparse(base)
    return f's3://{parsed.netloc}/' + posixpath.normpath(posixpath.join(posixpath.dirname(parsed.path.lstrip('/')), href))

def read_object(uri):
    p = urlparse(uri)
    assert p.scheme == 's3', uri
    return client.get_object(Bucket=p.netloc, Key=p.path.lstrip('/'))['Body'].read()

def check_catalog(uri, aoi):
    seen = set(); items = 0; rasters = 0
    def visit(href):
        nonlocal items, rasters
        if href in seen: return
        seen.add(href)
        d = json.loads(read_object(href))
        for link in d.get('links', []):
            if link['rel'] in ('root', 'self', 'parent'): json.loads(read_object(resolve(href, link['href'])))
            elif link['rel'] in ('item', 'child'): visit(resolve(href, link['href']))
        if d.get('type') != 'Feature': return
        items += 1
        assert d.get('geometry') and d.get('bbox'), href
        for asset in d.get('assets', {}).values():
            location = resolve(href, asset['href'])
            data = read_object(location)
            assert data, location
            if not location.lower().endswith(('.tif', '.tiff')): continue
            with MemoryFile(data) as memory, memory.open() as raster:
                assert raster.crs and raster.width > 0 and raster.height > 0, location
                bounds = transform_bounds(raster.crs, 'EPSG:4326', *raster.bounds)
                assert bounds[0] < aoi[2] and bounds[2] > aoi[0] and bounds[1] < aoi[3] and bounds[3] > aoi[1], (location, bounds)
                assert raster.read(1).size > 0
                rasters += 1
    visit(uri)
    assert items and rasters, (uri, items, rasters)
    return {'uri':uri, 'items':items, 'rasters':rasters, 'links_resolve':True, 'aoi_intersects':True}

for name, pattern, overrides in cases:
    if args.case and args.case != name: continue
    target = evidence / name; target.mkdir()
    params = json.loads((root / 'cwl-workflow' / f'{pattern}-inputs.json').read_text())
    params.update(overrides)
    params.update({'s3_bucket':args.bucket, 'sub_path':f'acceptance/{stamp}/{name}', 'aws_access_key_id':os.environ.get('AWS_ACCESS_KEY_ID','test'), 'aws_secret_access_key':os.environ.get('AWS_SECRET_ACCESS_KEY','test'), 'region_name':'us-east-1', 'endpoint_url':{'value':args.endpoint}})
    workflow = wrapping.compose(pattern, target / 'wrapped.cwl')
    job = target / 'params.json'; job.write_text(json.dumps(params))
    command = ['/opt/calrissian-venv/bin/calrissian','--max-ram','16G','--max-cores','8','--pod-serviceaccount','calrissian-sa','--tmpdir-prefix',str(target / 'tmp') + '/', '--outdir',str(target / 'results'),'--usage-report',str(target / 'usage.json'),'--tool-logs-basepath',str(target / 'logs')]
    if args.runner == 'cwltool': command = ['cwltool','--podman','--outdir',str(target / 'results')]
    command += ['--cachedir',str(args.output / 'cache'),str(workflow) + '#main',str(job)]
    print(f'Running {name}', flush=True)
    with (target / 'result.json').open('w') as out, (target / 'execution.log').open('w') as err:
        run = subprocess.run(command, stdout=out, stderr=err, env=os.environ | {'CWLTOOL_OPTIONS':''})
    record = {'case':name, 'exit_code':run.returncode, 'directory':str(target)}
    summary.append(record); (evidence / 'summary.json').write_text(json.dumps(summary,indent=2))
    if run.returncode:
        print((target / 'execution.log').read_text()[-8000:], flush=True); raise SystemExit(run.returncode)
    output = json.loads((target / 'result.json').read_text())
    catalogs = list(uris(output))
    assert len(catalogs) == len(set(catalogs)), ("Outputs must have distinct S3 catalogs", output)
    if pattern == 'pattern-6':
        import math
        assert not catalogs and isinstance(output.get('mean'), (int, float)) and math.isfinite(output['mean']), output
        assert -1 <= output['mean'] <= 1, output
        (target / 'scientific-check.json').write_text(json.dumps({'mean': output['mean'], 'finite_normalized_index': True}))
    elif name in ('pattern-8-output-unset','pattern-9-all-unset'): assert not catalogs, output
    else:
        assert catalogs, output
        checks = [check_catalog(uri, params['aoi']['bbox']) for uri in catalogs]
        (target / 'scientific-check.json').write_text(json.dumps(checks,indent=2))
    record['acceptance_passed'] = True
    (evidence / 'summary.json').write_text(json.dumps(summary,indent=2))
    print(f'PASSED {name}', flush=True)
assert summary, 'No acceptance cases selected'
print(f'All {len(summary)} cases passed; evidence: {evidence}', flush=True)
