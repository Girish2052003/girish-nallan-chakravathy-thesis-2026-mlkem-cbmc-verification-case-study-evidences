#!/usr/bin/env python3
from pathlib import Path
import sys
ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))
from verify_offline_fake_llm_cbmc_e2e import main
raise SystemExit(main("open_discovery"))
