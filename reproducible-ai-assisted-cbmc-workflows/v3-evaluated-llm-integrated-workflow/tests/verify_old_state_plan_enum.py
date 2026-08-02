#!/usr/bin/env python3

from jsonschema import validate, ValidationError
from agents.common.schemas import OLD_STATE_PLAN_SCHEMA

valid_values = [
    "required_for_selected_property",
    "partial_for_selected_property",
    "not_required_for_selected_property",
    "unknown_in_mock_mode",
    "not_required",
    "no",
]

for value in valid_values:
    validate(
        {
            "required": value,
            "reason": "test",
            "snapshot_items": [],
        },
        OLD_STATE_PLAN_SCHEMA,
    )

try:
    validate(
        {
            "required": ": partial",
            "reason": "malformed value",
            "snapshot_items": [],
        },
        OLD_STATE_PLAN_SCHEMA,
    )
except ValidationError:
    pass
else:
    raise AssertionError("Malformed ': partial' value was incorrectly accepted.")

print("OLD-STATE PLAN ENUM REGRESSION: PASS")
