"""Candidate testing must never substitute the shared staging runtime."""

import pytest
import yaml

from patterns.release import RUNNER_IMAGE, select_processing_image


def test_only_owned_runner_is_changed(tmp_path):
    path = tmp_path / "workflow.cwl"
    path.write_text(
        yaml.safe_dump(
            {
                "$graph": [
                    {
                        "requirements": {
                            "DockerRequirement": {"dockerPull": RUNNER_IMAGE + "@sha256:old"}
                        }
                    },
                    {
                        "requirements": [
                            {
                                "class": "DockerRequirement",
                                "dockerPull": "ghcr.io/eoap/mastering-app-package/stage-out:2.0.1",
                            }
                        ]
                    },
                    {
                        "types": [
                            {
                                "$import": "https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml"
                            }
                        ]
                    },
                ]
            }
        )
    )
    assert select_processing_image(path, "runner:accepted") == 1
    result = yaml.safe_load(path.read_text())["$graph"]
    assert result[0]["requirements"]["DockerRequirement"]["dockerPull"] == "runner:accepted"
    assert (
        result[1]["requirements"][0]["dockerPull"]
        == "ghcr.io/eoap/mastering-app-package/stage-out:2.0.1"
    )
    assert (
        result[2]["types"][0]["$import"]
        == "https://raw.githubusercontent.com/eoap/schemas/main/string_format.yaml"
    )


def test_missing_runner_is_an_error(tmp_path):
    path = tmp_path / "workflow.cwl"
    path.write_text("class: Workflow\n")
    with pytest.raises(ValueError, match="processing image"):
        select_processing_image(path, "runner:accepted")
