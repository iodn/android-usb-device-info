#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

DEFAULT_SQL_DUMP = ROOT / "assets" / "db_src" / "usbids.sql"
DEFAULT_OUT_DB = ROOT / "assets" / "db" / "usbids.sqlite"


def _cleanup_sidecars(db_path: Path) -> None:
    # Defensive: ensure no WAL/SHM sidecars remain in assets/
    for suffix in ("-wal", "-shm"):
        p = Path(str(db_path) + suffix)
        if p.exists():
            p.unlink()


def main() -> None:
    ap = argparse.ArgumentParser(description="Build assets/db/usbids.sqlite from assets/db_src/usbids.sql")
    ap.add_argument("--sql", default=str(DEFAULT_SQL_DUMP), help="Path to usbids.sql")
    ap.add_argument("--out", default=str(DEFAULT_OUT_DB), help="Output sqlite path")
    args = ap.parse_args()

    sql_dump = Path(args.sql)
    out_db = Path(args.out)

    if not sql_dump.exists():
        raise SystemExit(f"Missing SQL dump: {sql_dump}")

    out_db.parent.mkdir(parents=True, exist_ok=True)
    if out_db.exists():
        out_db.unlink()
    _cleanup_sidecars(out_db)

    sql = sql_dump.read_text(encoding="utf-8")

    con = sqlite3.connect(str(out_db))
    try:
        # Fast build settings
        con.execute("PRAGMA journal_mode=OFF;")
        con.execute("PRAGMA synchronous=OFF;")
        con.execute("PRAGMA temp_store=MEMORY;")

        con.executescript(sql)
        con.commit()

        # Switch back to a safer default for a shipped DB file
        con.execute("PRAGMA journal_mode=DELETE;")
        con.execute("PRAGMA optimize;")
        con.commit()
    finally:
        con.close()

    _cleanup_sidecars(out_db)

    if not out_db.exists() or out_db.stat().st_size < 1024:
        raise SystemExit(f"DB generation failed: {out_db}")

    print(f"[OK] Generated {out_db} ({out_db.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
