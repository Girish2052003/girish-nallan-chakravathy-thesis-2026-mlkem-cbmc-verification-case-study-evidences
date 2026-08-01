# MLK_POLY_FROMMSG harness collection

This directory contains one canonical copy of every unique harness SHA-256 discovered by the device audit.

- Original files were copied, not moved.
- Duplicate physical paths are retained in the lineage manifest.
- The native baseline harness is separated from the clean-room harnesses.
- The missing T4 integrity companion is not included here.
- The downloaded reconstruction must later be stored separately and labelled as reconstructed.

Verification command:

```bash
cd ~/THESIS-2026/mlk_poly_frommsg_cleanroom/harnesses
sha256sum -c manifests/FROMMSG_CANONICAL_HARNESS_SHA256SUMS.txt
```
