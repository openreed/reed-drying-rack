#!/usr/bin/env python3
"""Render rack/coupon variants, then check their actual exported STL meshes.

Uses only the Python standard library. Requires OpenSCAD 2021.01 or newer.
Run from any directory: python3 scripts/validate-models.py [--openscad PATH]
Generated meshes are local build outputs under the existing ignored 3D_files/.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import platform
import shutil
import struct
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / '3D_files' / 'mandrel-v2'


def mesh_info(path):
    raw = Path(path).read_bytes()
    count = struct.unpack_from('<I', raw, 80)[0]
    assert len(raw) == 84 + count * 50, f'{path}: expected binary STL'
    vertices, parent, edges = {}, [], Counter()
    bounds = [[float('inf')] * 3, [float('-inf')] * 3]
    volume = 0.0

    def find(i):
        while parent[i] != i:
            parent[i] = parent[parent[i]]
            i = parent[i]
        return i

    for offset in range(84, len(raw), 50):
        coords = struct.unpack_from('<12f', raw, offset)[3:]
        points = [coords[i:i+3] for i in (0, 3, 6)]
        ids = []
        for point in points:
            key = tuple(round(v, 5) for v in point)
            if key not in vertices:
                vertices[key] = len(parent)
                parent.append(len(parent))
            ids.append(vertices[key])
            for axis in range(3):
                bounds[0][axis] = min(bounds[0][axis], point[axis])
                bounds[1][axis] = max(bounds[1][axis], point[axis])
        assert len(set(ids)) == 3, f'{path}: degenerate triangle'
        for a, b in zip(ids, ids[1:]+ids[:1]):
            edges[tuple(sorted((a, b)))] += 1
            parent[find(a)] = find(b)
        a, b, c = points
        volume += (a[0]*(b[1]*c[2]-b[2]*c[1]) +
                   a[1]*(b[2]*c[0]-b[0]*c[2]) +
                   a[2]*(b[0]*c[1]-b[1]*c[0])) / 6
    assert all(n == 2 for n in edges.values()), f'{path}: open or nonmanifold edges'
    assert volume > 0, f'{path}: invalid or reversed volume'
    return {'triangles': count,
            'components': len({find(i) for i in range(len(parent))}),
            'bounds': bounds,
            'size_mm': [round(b-a, 4) for a, b in zip(*bounds)],
            'volume_mm3': round(volume, 2)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--openscad', default=shutil.which('openscad') or
                        '/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD')
    args = parser.parse_args()
    cli = [args.openscad]
    version = subprocess.run(cli+['--version'], capture_output=True, text=True)
    # Some universal macOS OpenSCAD builds reject the ARM feature probe.
    if version.returncode and platform.system() == 'Darwin' and 'neon' in version.stderr:
        cli = ['arch', '-x86_64', args.openscad]
        version = subprocess.run(cli+['--version'], capture_output=True, text=True)
    assert version.returncode == 0, version.stderr
    OUTPUT.mkdir(parents=True, exist_ok=True)
    results = {}

    def render(name, source, definitions, expected, persistent=True):
        target = OUTPUT / f'{name}.stl' if persistent else Path(temp_dir) / f'{name}.stl'
        command = cli + ['--hardwarnings', '--export-format', 'binstl', '-o', str(target)]
        for definition in definitions:
            command += ['-D', definition]
        result = subprocess.run(command+[str(ROOT/source)], capture_output=True, text=True)
        assert result.returncode == 0 and 'ERROR:' not in result.stderr, result.stderr
        info = mesh_info(target)
        assert info['components'] == 1, f'{name}: disconnected geometry: {info}'
        assert abs(info['bounds'][0][2]) < 0.001, f'{name}: does not start at bed'
        assert all(abs(a-b) < 0.02 for a, b in zip(info['size_mm'], expected)), (name, info)
        results[name] = info

    with tempfile.TemporaryDirectory(prefix='openreed-validation-') as temp_dir:
        for family, suffix, rack_size, coupon_size in [
            ('oboe_english_horn', 'oboe-english-horn', [160, 80, 23], [112, 76, 17]),
            ('bassoon', 'bassoon', [192, 96, 25], [132, 88, 19]),
        ]:
            render(f'rack-{suffix}', 'protruding-reed-rack.scad',
                   [f'ReedFamily="{family}"', 'NumberOfStaples=[8,4]'], rack_size)
            render(f'fit-{suffix}', 'fit-tests/mandrel-fit-test.scad',
                   [f'ReedFamily="{family}"'], coupon_size)
        # Preserve the historical A5 export after the live profile moves to A1.
        render('rack-oboe-a5', 'fit-tests/historical-rack.scad',
               ['ReedFamily="custom"', 'StapleBottomDiameter=4.9',
                'StapleTopDiameter=4.0', 'StapleHeight=12', 'StopDiameter=8',
                'NumberOfStaples=[3,2]'], [60,40,22])
        render('fit-oboe-round2', 'fit-tests/mandrel-fit-test.scad',
               ['ReedFamily="oboe"', 'TestRound=2'], [72,76,17])
        render('single-pin', 'protruding-reed-rack.scad',
               ['NumberOfStaples=[1,1]'], [20,20,23], False)
        render('custom-root', 'protruding-reed-rack.scad',
               ['ReedFamily="custom"', 'NumberOfStaples=[1,1]',
                'EdgeChamfer=0', 'StapleBottomDiameter=4.6', 'StapleTopDiameter=3.0',
                'StapleHeight=10', 'DiameterCompensation=-0.1',
                'RootHeight=3', 'RootDiameter=9', 'TipChamfer=0'], [20,20,21], False)
        # Check that the original air-gap bug cannot return via either profile.
        # Also exercise both supported compensation extremes and 1-cell sweeps.
        for correction in [-0.4, 0.4]:
            render(f'compensation-{correction}', 'protruding-reed-rack.scad',
                   ['NumberOfStaples=[1,1]', f'DiameterCompensation={correction}'],
                   [20,20,23], False)
        render('custom-sweep', 'fit-tests/mandrel-fit-test.scad',
               ['UseCustomSweep=true', 'CustomBottomDiameters=[4.4]',
                'CustomTapers=[0.1]', 'CustomHeight=10'], [32,36,15], False)
        # Invalid geometry must fail loudly, even on OpenSCAD versions returning 0.
        invalid_cases = [
            ['NumberOfStaples=[0,2]'], ['NumberOfStaples=[1.5,2]'],
            ['ReedFamily="typo"'], ['RootHeight=0'],
            ['ReedFamily="custom"', 'StapleTopDiameter=5'],
        ]
        for i, definitions in enumerate(invalid_cases):
            command = cli+['-o', str(Path(temp_dir)/f'invalid-{i}.stl')]
            for definition in definitions:
                command += ['-D', definition]
            result = subprocess.run(command+[str(ROOT/'protruding-reed-rack.scad')],
                                    capture_output=True, text=True)
            assert 'ERROR:' in result.stderr, f'Invalid case accepted: {definitions}'
    print(json.dumps({'openscad': (version.stdout+version.stderr).strip(),
                      'meshes': results, 'invalid_cases_rejected': len(invalid_cases)}, indent=2))


if __name__ == '__main__':
    main()
