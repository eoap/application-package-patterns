"""
EOAP CWLWrap (c) 2025

EOAP CWLWrap is licensed under
Creative Commons Attribution-ShareAlike 4.0 International.

You should have received a copy of the license along with this work.
If not, see <https://creativecommons.org/licenses/by-sa/4.0/>.
"""

import os
import sys
import unittest
from cwltool.main import main as cwlmain
from cwltool.context import LoadingContext, RuntimeContext
from cwltool.executors import NoopJobExecutor
from cwl_loader import dump_cwl
from io import StringIO
from click.testing import CliRunner
import importlib.util
from pathlib import Path


class TestCWL(unittest.TestCase):

    def validate_cwl_file(self, cwl_file) -> int:
        args = ["--enable-ext", "--validate", cwl_file]

        stream_err = StringIO()
        stream_out = StringIO()

        result = cwlmain(
            args,
            stdout=stream_out,
            stderr=stream_err,
            executor=NoopJobExecutor(),
            loadingContext=LoadingContext(),
            runtimeContext=RuntimeContext(),
        )
        if result != 0:
            print(stream_out.getvalue(), file=sys.stderr)
            raise RuntimeError(f"Validation failed with exit code {result}")
        return result

    def setUp(self):
        self.output = ".wrapped.cwl"
        self.base_url = ".."
        self.entrypoint = None

    def tearDown(self):
        if os.path.exists(self.output):
            os.remove(self.output)

    def _cwl_validation(self, app_cwl_file):
        return self.validate_cwl_file(app_cwl_file)

    def _wrapped_cwl_validation(self):
        root = Path(__file__).resolve().parents[2]
        spec = importlib.util.spec_from_file_location('pattern_wrap', root / 'scripts/wrap-pattern.py')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        module.compose(self.entrypoint, Path(self.output))

        self.assertEqual(self._cwl_validation(".wrapped.cwl"), 0)
