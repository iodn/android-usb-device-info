#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import re
import sqlite3
import struct
import tempfile
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, Tuple
import zlib

# usb.ids parsing patterns
RE_META_VERSION = re.compile(r"^#\s*Version:\s*(.+)\s*$")
RE_META_DATE = re.compile(r"^#\s*Date:\s*(.+)\s*$")

RE_VENDOR = re.compile(r"^([0-9A-Fa-f]{4})\s+(.+)$")
RE_DEVICE = re.compile(r"^([0-9A-Fa-f]{4})\s+(.+)$")
RE_INTERFACE = re.compile(r"^([0-9A-Fa-f]{2,4})\s+(.+)$")

RE_CLASS = re.compile(r"^C\s+([0-9A-Fa-f]{2})\s+(.+)$")
RE_SUBCLASS = re.compile(r"^([0-9A-Fa-f]{2})\s+(.+)$")
RE_PROTOCOL = re.compile(r"^([0-9A-Fa-f]{2})\s+(.+)$")

RE_AT = re.compile(r"^AT\s+([0-9A-Fa-f]{4})\s+(.+)$")
RE_HID_DESC = re.compile(r"^HID\s+([0-9A-Fa-f]{2})\s+(.+)$")
RE_R_ITEM = re.compile(r"^R\s+([0-9A-Fa-f]{2})\s+(.+)$")
RE_BIAS = re.compile(r"^BIAS\s+(\d+)\s+(.+)$")
RE_PHY = re.compile(r"^PHY\s+([0-9A-Fa-f]{2})\s+(.+)$")

RE_HUT_PAGE = re.compile(r"^HUT\s+([0-9A-Fa-f]{2})\s+(.+)$")
RE_HUT_USAGE = re.compile(r"^([0-9A-Fa-f]{1,4})\s+(.+)$")


@dataclass
class ParseState:
    current_vid: Optional[int] = None
    current_pid: Optional[int] = None

    current_class: Optional[int] = None
    current_subclass: Optional[int] = None

    current_hut_page: Optional[int] = None

    meta_version: Optional[str] = None
    meta_date: Optional[str] = None


# SQLite schema (NO WAL)
SCHEMA_SQL = """
CREATE TABLE IF NOT EXISTS meta (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS vendors (
  vid  INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS products (
  vid  INTEGER NOT NULL,
  pid  INTEGER NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (vid, pid),
  FOREIGN KEY (vid) REFERENCES vendors(vid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS interfaces (
  vid  INTEGER NOT NULL,
  pid  INTEGER NOT NULL,
  iid  INTEGER NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (vid, pid, iid),
  FOREIGN KEY (vid, pid) REFERENCES products(vid, pid) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS usb_classes (
  class_id INTEGER PRIMARY KEY,
  name     TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS usb_subclasses (
  class_id    INTEGER NOT NULL,
  subclass_id INTEGER NOT NULL,
  name        TEXT NOT NULL,
  PRIMARY KEY (class_id, subclass_id),
  FOREIGN KEY (class_id) REFERENCES usb_classes(class_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS usb_protocols (
  class_id    INTEGER NOT NULL,
  subclass_id INTEGER NOT NULL,
  protocol_id INTEGER NOT NULL,
  name        TEXT NOT NULL,
  PRIMARY KEY (class_id, subclass_id, protocol_id),
  FOREIGN KEY (class_id, subclass_id) REFERENCES usb_subclasses(class_id, subclass_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS audio_terminal_types (
  terminal_type INTEGER PRIMARY KEY,
  name          TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS hid_descriptor_types (
  descriptor_type INTEGER PRIMARY KEY,
  name            TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS hid_descriptor_item_types (
  item_type INTEGER PRIMARY KEY,
  name      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS physical_bias_types (
  bias_type INTEGER PRIMARY KEY,
  name      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS physical_descriptor_item_types (
  item_type INTEGER PRIMARY KEY,
  name      TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS hid_usage_pages (
  page_id INTEGER PRIMARY KEY,
  name    TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS hid_usages (
  page_id  INTEGER NOT NULL,
  usage_id INTEGER NOT NULL,
  name     TEXT NOT NULL,
  PRIMARY KEY (page_id, usage_id),
  FOREIGN KEY (page_id) REFERENCES hid_usage_pages(page_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_products_pid ON products(pid);
CREATE INDEX IF NOT EXISTS idx_products_vid ON products(vid);
CREATE INDEX IF NOT EXISTS idx_interfaces_iid ON interfaces(iid);
CREATE INDEX IF NOT EXISTS idx_hid_usages_usage ON hid_usages(usage_id);
"""


def _count_leading_tabs(line: str) -> Tuple[int, str]:
    tabs = 0
    n = len(line)
    while tabs < n and line[tabs] == "\t":
        tabs += 1
    return tabs, line[tabs:]


def _to_int_hex(s: str) -> int:
    return int(s, 16)


def _sha256_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def _write_sha256_sidecar(target_file: Path, out_sha_path: Path) -> str:
    """
    Writes a sha256 sidecar file containing the hex digest + newline.
    Returns the digest.
    """
    digest = _sha256_file(target_file)
    out_sha_path.parent.mkdir(parents=True, exist_ok=True)
    out_sha_path.write_text(digest + "\n", encoding="utf-8", newline="\n")
    return digest


def download_usb_ids(url: str, out_path: Path, timeout: int = 60) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    req = urllib.request.Request(
        url,
        headers={
            "User-Agent": "usbdevinfo-usbids-updater/1.1 (+https://github.com/)",
            "Accept": "text/plain,*/*",
        },
    )
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        if getattr(resp, "status", 200) != 200:
            raise SystemExit(f"Download failed: HTTP {resp.status}")
        data = resp.read()
    out_path.write_bytes(data)


def build_sqlite_from_usb_ids(input_path: Path, output_db: Path, vacuum: bool) -> ParseState:
    if not input_path.exists():
        raise FileNotFoundError(f"Input file not found: {input_path}")

    if output_db.exists():
        output_db.unlink()

    state = ParseState()

    con = sqlite3.connect(str(output_db))
    try:
        con.execute("PRAGMA journal_mode=OFF;")
        con.execute("PRAGMA synchronous=OFF;")
        con.execute("PRAGMA temp_store=MEMORY;")
        con.execute("PRAGMA locking_mode=EXCLUSIVE;")
        con.execute("PRAGMA foreign_keys=ON;")
        con.executescript(SCHEMA_SQL)

        cur = con.cursor()
        cur.execute("BEGIN;")

        def upsert_meta(key: str, value: str) -> None:
            cur.execute(
                "INSERT INTO meta(key, value) VALUES(?, ?) "
                "ON CONFLICT(key) DO UPDATE SET value=excluded.value;",
                (key, value),
            )

        def upsert_vendor(vid: int, name: str) -> None:
            cur.execute(
                "INSERT INTO vendors(vid, name) VALUES(?, ?) "
                "ON CONFLICT(vid) DO UPDATE SET name=excluded.name;",
                (vid, name),
            )

        def upsert_product(vid: int, pid: int, name: str) -> None:
            cur.execute(
                "INSERT INTO products(vid, pid, name) VALUES(?, ?, ?) "
                "ON CONFLICT(vid, pid) DO UPDATE SET name=excluded.name;",
                (vid, pid, name),
            )

        def upsert_interface(vid: int, pid: int, iid: int, name: str) -> None:
            cur.execute(
                "INSERT INTO interfaces(vid, pid, iid, name) VALUES(?, ?, ?, ?) "
                "ON CONFLICT(vid, pid, iid) DO UPDATE SET name=excluded.name;",
                (vid, pid, iid, name),
            )

        def upsert_class(class_id: int, name: str) -> None:
            cur.execute(
                "INSERT INTO usb_classes(class_id, name) VALUES(?, ?) "
                "ON CONFLICT(class_id) DO UPDATE SET name=excluded.name;",
                (class_id, name),
            )

        def upsert_subclass(class_id: int, subclass_id: int, name: str) -> None:
            cur.execute(
                "INSERT INTO usb_subclasses(class_id, subclass_id, name) VALUES(?, ?, ?) "
                "ON CONFLICT(class_id, subclass_id) DO UPDATE SET name=excluded.name;",
                (class_id, subclass_id, name),
            )

        def upsert_protocol(class_id: int, subclass_id: int, protocol_id: int, name: str) -> None:
            cur.execute(
                "INSERT INTO usb_protocols(class_id, subclass_id, protocol_id, name) VALUES(?, ?, ?, ?) "
                "ON CONFLICT(class_id, subclass_id, protocol_id) DO UPDATE SET name=excluded.name;",
                (class_id, subclass_id, protocol_id, name),
            )

        def upsert_at(term_type: int, name: str) -> None:
            cur.execute(
                "INSERT INTO audio_terminal_types(terminal_type, name) VALUES(?, ?) "
                "ON CONFLICT(terminal_type) DO UPDATE SET name=excluded.name;",
                (term_type, name),
            )

        def upsert_hid_desc(code: int, name: str) -> None:
            cur.execute(
                "INSERT INTO hid_descriptor_types(descriptor_type, name) VALUES(?, ?) "
                "ON CONFLICT(descriptor_type) DO UPDATE SET name=excluded.name;",
                (code, name),
            )

        def upsert_r_item(code: int, name: str) -> None:
            cur.execute(
                "INSERT INTO hid_descriptor_item_types(item_type, name) VALUES(?, ?) "
                "ON CONFLICT(item_type) DO UPDATE SET name=excluded.name;",
                (code, name),
            )

        def upsert_bias(code: int, name: str) -> None:
            cur.execute(
                "INSERT INTO physical_bias_types(bias_type, name) VALUES(?, ?) "
                "ON CONFLICT(bias_type) DO UPDATE SET name=excluded.name;",
                (code, name),
            )

        def upsert_phy(code: int, name: str) -> None:
            cur.execute(
                "INSERT INTO physical_descriptor_item_types(item_type, name) VALUES(?, ?) "
                "ON CONFLICT(item_type) DO UPDATE SET name=excluded.name;",
                (code, name),
            )

        def upsert_hut_page(page_id: int, name: str) -> None:
            cur.execute(
                "INSERT INTO hid_usage_pages(page_id, name) VALUES(?, ?) "
                "ON CONFLICT(page_id) DO UPDATE SET name=excluded.name;",
                (page_id, name),
            )

        def upsert_hut_usage(page_id: int, usage_id: int, name: str) -> None:
            cur.execute(
                "INSERT INTO hid_usages(page_id, usage_id, name) VALUES(?, ?, ?) "
                "ON CONFLICT(page_id, usage_id) DO UPDATE SET name=excluded.name;",
                (page_id, usage_id, name),
            )

        with input_path.open("r", encoding="utf-8", errors="replace") as f:
            for raw_line in f:
                line = raw_line.rstrip("\n")

                if line.startswith("#"):
                    m = RE_META_VERSION.match(line)
                    if m:
                        state.meta_version = m.group(1).strip()
                        continue
                    m = RE_META_DATE.match(line)
                    if m:
                        state.meta_date = m.group(1).strip()
                        continue
                    continue

                if not line.strip():
                    continue

                # Tagged sections
                m = RE_AT.match(line)
                if m:
                    upsert_at(_to_int_hex(m.group(1)), m.group(2).strip())
                    continue

                m = RE_HID_DESC.match(line)
                if m:
                    upsert_hid_desc(_to_int_hex(m.group(1)), m.group(2).strip())
                    continue

                m = RE_R_ITEM.match(line)
                if m:
                    upsert_r_item(_to_int_hex(m.group(1)), m.group(2).strip())
                    continue

                m = RE_BIAS.match(line)
                if m:
                    upsert_bias(int(m.group(1)), m.group(2).strip())
                    continue

                m = RE_PHY.match(line)
                if m:
                    upsert_phy(_to_int_hex(m.group(1)), m.group(2).strip())
                    continue

                # HUT page header
                m = RE_HUT_PAGE.match(line)
                if m:
                    state.current_hut_page = _to_int_hex(m.group(1))
                    upsert_hut_page(state.current_hut_page, m.group(2).strip())
                    # Avoid consuming vendor/class indents accidentally
                    state.current_class = None
                    state.current_subclass = None
                    state.current_vid = None
                    state.current_pid = None
                    continue

                # USB class header
                m = RE_CLASS.match(line)
                if m:
                    state.current_class = _to_int_hex(m.group(1))
                    state.current_subclass = None
                    upsert_class(state.current_class, m.group(2).strip())
                    # Avoid consuming vendor/HUT indents accidentally
                    state.current_hut_page = None
                    state.current_vid = None
                    state.current_pid = None
                    continue

                tabs, rest = _count_leading_tabs(line)
                rest = rest.rstrip()

                # HUT usages
                if tabs == 1 and state.current_hut_page is not None:
                    m = RE_HUT_USAGE.match(rest)
                    if m:
                        upsert_hut_usage(state.current_hut_page, _to_int_hex(m.group(1)), m.group(2).strip())
                        continue

                # Subclass/protocol lines under a class
                if state.current_class is not None:
                    if tabs == 1:
                        m = RE_SUBCLASS.match(rest)
                        if m:
                            state.current_subclass = _to_int_hex(m.group(1))
                            upsert_subclass(state.current_class, state.current_subclass, m.group(2).strip())
                            continue
                    elif tabs == 2 and state.current_subclass is not None:
                        m = RE_PROTOCOL.match(rest)
                        if m:
                            upsert_protocol(
                                state.current_class,
                                state.current_subclass,
                                _to_int_hex(m.group(1)),
                                m.group(2).strip(),
                            )
                            continue

                # Vendor/device/interface tree
                if tabs == 0:
                    m = RE_VENDOR.match(rest)
                    if m:
                        state.current_vid = _to_int_hex(m.group(1))
                        state.current_pid = None
                        upsert_vendor(state.current_vid, m.group(2).strip())
                        # Leave other contexts
                        state.current_hut_page = None
                        state.current_class = None
                        state.current_subclass = None
                        continue

                if tabs == 1 and state.current_vid is not None:
                    m = RE_DEVICE.match(rest)
                    if m:
                        state.current_pid = _to_int_hex(m.group(1))
                        upsert_product(state.current_vid, state.current_pid, m.group(2).strip())
                        continue

                if tabs == 2 and state.current_vid is not None and state.current_pid is not None:
                    m = RE_INTERFACE.match(rest)
                    if m:
                        upsert_interface(state.current_vid, state.current_pid, _to_int_hex(m.group(1)), m.group(2).strip())
                        continue

        # Metadata
        if state.meta_version:
            upsert_meta("version", state.meta_version)
        if state.meta_date:
            upsert_meta("date", state.meta_date)
        upsert_meta("source_format", "usb.ids")

        cur.execute("COMMIT;")

        if vacuum:
            con.execute("VACUUM;")

        con.execute("PRAGMA optimize;")

    finally:
        con.close()

    return state


def dump_sql(db_path: Path, out_sql: Path, header: str) -> None:
    out_sql.parent.mkdir(parents=True, exist_ok=True)
    with sqlite3.connect(str(db_path)) as con, out_sql.open("w", encoding="utf-8", newline="\n") as f:
        f.write("-- " + header.replace("\n", "\n-- ") + "\n")
        for stmt in con.iterdump():
            f.write(stmt)
            f.write("\n")


def gzip_file(src: Path, dst_gz: Path, compresslevel: int = 9) -> None:
    """
    Write a gzip file with a deterministic header (mtime=0) without relying on
    gzip.open(mtime=...), which is not available on older Python versions.
    """
    dst_gz.parent.mkdir(parents=True, exist_ok=True)

    # GZIP header (RFC 1952)
    xfl = 2 if compresslevel >= 9 else 0  # "maximum compression" hint

    crc = 0
    size = 0
    compressor = zlib.compressobj(
        compresslevel, zlib.DEFLATED, -zlib.MAX_WBITS
    )  # raw DEFLATE stream

    with src.open("rb") as fin, dst_gz.open("wb") as fout:
        fout.write(b"\x1f\x8b")            # ID1, ID2
        fout.write(b"\x08")                # CM = DEFLATE
        fout.write(b"\x00")                # FLG = 0 (no extra fields)
        fout.write(b"\x00\x00\x00\x00")    # MTIME = 0 (deterministic)
        fout.write(bytes([xfl]))           # XFL
        fout.write(b"\xff")                # OS = 255 (unknown)

        while True:
            chunk = fin.read(1024 * 1024)
            if not chunk:
                break
            size = (size + len(chunk)) & 0xFFFFFFFF
            crc = zlib.crc32(chunk, crc) & 0xFFFFFFFF
            data = compressor.compress(chunk)
            if data:
                fout.write(data)

        tail = compressor.flush()
        if tail:
            fout.write(tail)

        # GZIP trailer: CRC32 + ISIZE (both little-endian uint32)
        fout.write(struct.pack("<I", crc))
        fout.write(struct.pack("<I", size))


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Fetch linux-usb usb.ids, build sqlite DB, write usbids.sql, usbids.sqlite.gz, and usbids.sqlite.gz.sha256"
    )
    ap.add_argument(
        "--url",
        default="http://www.linux-usb.org/usb.ids",
        help="Upstream usb.ids URL (default: http://www.linux-usb.org/usb.ids)",
    )
    ap.add_argument("--out-sql", default=None, help="Output SQL path (default: assets/db_src/usbids.sql)")
    ap.add_argument("--out-gz", default=None, help="Output gzip sqlite path (default: assets/db_src/usbids.sqlite.gz)")
    ap.add_argument(
        "--out-gz-sha256",
        default=None,
        help="Output sha256 sidecar for gzip (default: assets/db_src/usbids.sqlite.gz.sha256)",
    )
    ap.add_argument("--timeout", type=int, default=60, help="Download timeout seconds (default: 60)")
    ap.add_argument("--no-vacuum", action="store_true", help="Skip VACUUM (faster, slightly bigger DB)")
    args = ap.parse_args()

    ROOT = Path(__file__).resolve().parents[1]
    out_sql = Path(args.out_sql) if args.out_sql else (ROOT / "assets" / "db_src" / "usbids.sql")
    out_gz = Path(args.out_gz) if args.out_gz else (ROOT / "assets" / "db_src" / "usbids.sqlite.gz")
    out_gz_sha = Path(args.out_gz_sha256) if args.out_gz_sha256 else (ROOT / "assets" / "db_src" / "usbids.sqlite.gz.sha256")

    with tempfile.TemporaryDirectory(prefix="usbids_update_") as td:
        td_path = Path(td)
        ids_txt = td_path / "usb.ids"
        db_path = td_path / "usbids.sqlite"

        download_usb_ids(args.url, ids_txt, timeout=args.timeout)

        state = build_sqlite_from_usb_ids(ids_txt, db_path, vacuum=(not args.no_vacuum))

        header = (
            f"Generated by tools/update_usbids_artifacts.py\n"
            f"Source: {args.url}\n"
            f"usb.ids Version: {state.meta_version or 'unknown'}\n"
            f"usb.ids Date: {state.meta_date or 'unknown'}"
        )
        dump_sql(db_path, out_sql, header)

        gzip_file(db_path, out_gz, compresslevel=9)
        gz_digest = _write_sha256_sidecar(out_gz, out_gz_sha)

        print("[OK] Wrote:")
        print(f"  - {out_sql} ({out_sql.stat().st_size} bytes)")
        print(f"  - {out_gz} ({out_gz.stat().st_size} bytes)")
        print(f"  - {out_gz_sha} ({out_gz_sha.stat().st_size} bytes)")
        print("[OK] Checksums:")
        print(f"  - usbids.sql                 sha256={_sha256_file(out_sql)}")
        print(f"  - usbids.sqlite.gz           sha256={gz_digest}")
        print(f"  - usbids.sqlite.gz.sha256    sha256={_sha256_file(out_gz_sha)}")


if __name__ == "__main__":
    main()
