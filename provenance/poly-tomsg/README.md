# `mlk_poly_tomsg` Provenance

`source-snapshots/` represents the frozen mlkem-native source tree supplied with the campaign. During import, files whose exact SHA-256 already exists in the repository's upstream source snapshot may be skipped and recorded in the import report rather than copied again.

The incoming source snapshot's `.git` file is preserved as ordinary audit text under `quarantined-git-pointers/`. It must not be installed as a nested Git pointer inside the evidence repository.
