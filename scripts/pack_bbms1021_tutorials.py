#!/usr/bin/env python3
"""Deprecated shim — use scripts/pack_tutorials.py instead."""

from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import pack_tutorials  # noqa: E402


if __name__ == "__main__":
    print(
        "note: scripts/pack_bbms1021_tutorials.py is deprecated; "
        "use scripts/pack_tutorials.py",
        file=sys.stderr,
    )
    sys.exit(pack_tutorials.main())
