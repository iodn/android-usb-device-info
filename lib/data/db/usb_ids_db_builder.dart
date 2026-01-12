import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:sqflite/sqflite.dart';

class UsbIdsParsedMeta {
  UsbIdsParsedMeta({this.version, this.date});

  String? version;
  String? date;
}

class UsbIdsDbBuilder {
  static const List<String> _schemaStatements = [
    'PRAGMA journal_mode=OFF;',
    'PRAGMA synchronous=OFF;',
    'PRAGMA temp_store=MEMORY;',
    'PRAGMA foreign_keys=ON;',
    '''
CREATE TABLE IF NOT EXISTS meta (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS vendors (
  vid  INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS products (
  vid  INTEGER NOT NULL,
  pid  INTEGER NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (vid, pid),
  FOREIGN KEY (vid) REFERENCES vendors(vid) ON DELETE CASCADE
);
''',
    '''
CREATE TABLE IF NOT EXISTS interfaces (
  vid  INTEGER NOT NULL,
  pid  INTEGER NOT NULL,
  iid  INTEGER NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (vid, pid, iid),
  FOREIGN KEY (vid, pid) REFERENCES products(vid, pid) ON DELETE CASCADE
);
''',
    '''
CREATE TABLE IF NOT EXISTS usb_classes (
  class_id INTEGER PRIMARY KEY,
  name     TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS usb_subclasses (
  class_id    INTEGER NOT NULL,
  subclass_id INTEGER NOT NULL,
  name        TEXT NOT NULL,
  PRIMARY KEY (class_id, subclass_id),
  FOREIGN KEY (class_id) REFERENCES usb_classes(class_id) ON DELETE CASCADE
);
''',
    '''
CREATE TABLE IF NOT EXISTS usb_protocols (
  class_id    INTEGER NOT NULL,
  subclass_id INTEGER NOT NULL,
  protocol_id INTEGER NOT NULL,
  name        TEXT NOT NULL,
  PRIMARY KEY (class_id, subclass_id, protocol_id),
  FOREIGN KEY (class_id, subclass_id) REFERENCES usb_subclasses(class_id, subclass_id) ON DELETE CASCADE
);
''',
    '''
CREATE TABLE IF NOT EXISTS audio_terminal_types (
  terminal_type INTEGER PRIMARY KEY,
  name          TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS hid_descriptor_types (
  descriptor_type INTEGER PRIMARY KEY,
  name            TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS hid_descriptor_item_types (
  item_type INTEGER PRIMARY KEY,
  name      TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS physical_bias_types (
  bias_type INTEGER PRIMARY KEY,
  name      TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS physical_descriptor_item_types (
  item_type INTEGER PRIMARY KEY,
  name      TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS hid_usage_pages (
  page_id INTEGER PRIMARY KEY,
  name    TEXT NOT NULL
);
''',
    '''
CREATE TABLE IF NOT EXISTS hid_usages (
  page_id  INTEGER NOT NULL,
  usage_id INTEGER NOT NULL,
  name     TEXT NOT NULL,
  PRIMARY KEY (page_id, usage_id),
  FOREIGN KEY (page_id) REFERENCES hid_usage_pages(page_id) ON DELETE CASCADE
);
''',
    'CREATE INDEX IF NOT EXISTS idx_products_pid ON products(pid);',
    'CREATE INDEX IF NOT EXISTS idx_products_vid ON products(vid);',
    'CREATE INDEX IF NOT EXISTS idx_interfaces_iid ON interfaces(iid);',
    'CREATE INDEX IF NOT EXISTS idx_hid_usages_usage ON hid_usages(usage_id);',
  ];

  /* Regex */
  static final RegExp _reMetaVersion = RegExp(r'^#\s*Version:\s*(.+)\s*$');
  static final RegExp _reMetaDate = RegExp(r'^#\s*Date:\s*(.+)\s*$');

  static final RegExp _reVendor = RegExp(r'^([0-9A-Fa-f]{4})\s+(.+)$');
  static final RegExp _reDevice = RegExp(r'^([0-9A-Fa-f]{4})\s+(.+)$');
  static final RegExp _reInterface = RegExp(r'^([0-9A-Fa-f]{2,4})\s+(.+)$');

  static final RegExp _reClass = RegExp(r'^C\s+([0-9A-Fa-f]{2})\s+(.+)$');
  static final RegExp _reSubclass = RegExp(r'^([0-9A-Fa-f]{2})\s+(.+)$');
  static final RegExp _reProtocol = RegExp(r'^([0-9A-Fa-f]{2})\s+(.+)$');

  static final RegExp _reAT = RegExp(r'^AT\s+([0-9A-Fa-f]{4})\s+(.+)$');
  static final RegExp _reHidDesc = RegExp(r'^HID\s+([0-9A-Fa-f]{2})\s+(.+)$');
  static final RegExp _reRItem = RegExp(r'^R\s+([0-9A-Fa-f]{2})\s+(.+)$');
  static final RegExp _reBias = RegExp(r'^BIAS\s+(\d+)\s+(.+)$');
  static final RegExp _rePhy = RegExp(r'^PHY\s+([0-9A-Fa-f]{2})\s+(.+)$');

  static final RegExp _reHutPage = RegExp(r'^HUT\s+([0-9A-Fa-f]{2})\s+(.+)$');
  static final RegExp _reHutUsage = RegExp(r'^([0-9A-Fa-f]{1,4})\s+(.+)$');

  static int _hexToInt(String s) => int.parse(s, radix: 16);

  static ({int tabs, String rest}) _countLeadingTabs(String line) {
    int tabs = 0;
    while (tabs < line.length && line.startsWith('\t' * (tabs + 1))) {
      tabs++;
    }
    return (tabs: tabs, rest: line.substring(tabs));
  }

  static Future<UsbIdsParsedMeta> build({
    required String usbIdsPath,
    required String outDbPath,
    required String checksumFnv64,
  }) async {
    final file = File(usbIdsPath);
    if (!await file.exists()) {
      throw StateError('usb.ids file not found: $usbIdsPath');
    }

    /* Ensure fresh output */
    await deleteDatabase(outDbPath);

    final db = await openDatabase(outDbPath, version: 1);
    try {
      for (final s in _schemaStatements) {
        await db.execute(s);
      }

      final meta = UsbIdsParsedMeta();

      int? currentVid;
      int? currentPid;

      int? currentClass;
      int? currentSubclass;

      int? currentHutPage;

      /* Helper: portable upsert = UPDATE then INSERT OR IGNORE. */
      Future<void> upsertMeta(Batch b, String key, String value) async {
        b.rawUpdate('UPDATE meta SET value=? WHERE key=?', [value, key]);
        b.rawInsert('INSERT OR IGNORE INTO meta(key,value) VALUES(?,?)', [key, value]);
      }

      void upsertVendor(Batch b, int vid, String name) {
        b.rawUpdate('UPDATE vendors SET name=? WHERE vid=?', [name, vid]);
        b.rawInsert('INSERT OR IGNORE INTO vendors(vid,name) VALUES(?,?)', [vid, name]);
      }

      void upsertProduct(Batch b, int vid, int pid, String name) {
        b.rawUpdate('UPDATE products SET name=? WHERE vid=? AND pid=?', [name, vid, pid]);
        b.rawInsert('INSERT OR IGNORE INTO products(vid,pid,name) VALUES(?,?,?)', [vid, pid, name]);
      }

      void upsertInterface(Batch b, int vid, int pid, int iid, String name) {
        b.rawUpdate('UPDATE interfaces SET name=? WHERE vid=? AND pid=? AND iid=?', [name, vid, pid, iid]);
        b.rawInsert(
          'INSERT OR IGNORE INTO interfaces(vid,pid,iid,name) VALUES(?,?,?,?)',
          [vid, pid, iid, name],
        );
      }

      void upsertClass(Batch b, int classId, String name) {
        b.rawUpdate('UPDATE usb_classes SET name=? WHERE class_id=?', [name, classId]);
        b.rawInsert('INSERT OR IGNORE INTO usb_classes(class_id,name) VALUES(?,?)', [classId, name]);
      }

      void upsertSubclass(Batch b, int classId, int subclassId, String name) {
        b.rawUpdate(
          'UPDATE usb_subclasses SET name=? WHERE class_id=? AND subclass_id=?',
          [name, classId, subclassId],
        );
        b.rawInsert(
          'INSERT OR IGNORE INTO usb_subclasses(class_id,subclass_id,name) VALUES(?,?,?)',
          [classId, subclassId, name],
        );
      }

      void upsertProtocol(Batch b, int classId, int subclassId, int protocolId, String name) {
        b.rawUpdate(
          'UPDATE usb_protocols SET name=? WHERE class_id=? AND subclass_id=? AND protocol_id=?',
          [name, classId, subclassId, protocolId],
        );
        b.rawInsert(
          'INSERT OR IGNORE INTO usb_protocols(class_id,subclass_id,protocol_id,name) VALUES(?,?,?,?)',
          [classId, subclassId, protocolId, name],
        );
      }

      void upsertAT(Batch b, int termType, String name) {
        b.rawUpdate('UPDATE audio_terminal_types SET name=? WHERE terminal_type=?', [name, termType]);
        b.rawInsert(
          'INSERT OR IGNORE INTO audio_terminal_types(terminal_type,name) VALUES(?,?)',
          [termType, name],
        );
      }

      void upsertHidDesc(Batch b, int code, String name) {
        b.rawUpdate('UPDATE hid_descriptor_types SET name=? WHERE descriptor_type=?', [name, code]);
        b.rawInsert(
          'INSERT OR IGNORE INTO hid_descriptor_types(descriptor_type,name) VALUES(?,?)',
          [code, name],
        );
      }

      void upsertRItem(Batch b, int code, String name) {
        b.rawUpdate('UPDATE hid_descriptor_item_types SET name=? WHERE item_type=?', [name, code]);
        b.rawInsert(
          'INSERT OR IGNORE INTO hid_descriptor_item_types(item_type,name) VALUES(?,?)',
          [code, name],
        );
      }

      void upsertBias(Batch b, int code, String name) {
        b.rawUpdate('UPDATE physical_bias_types SET name=? WHERE bias_type=?', [name, code]);
        b.rawInsert('INSERT OR IGNORE INTO physical_bias_types(bias_type,name) VALUES(?,?)', [code, name]);
      }

      void upsertPhy(Batch b, int code, String name) {
        b.rawUpdate('UPDATE physical_descriptor_item_types SET name=? WHERE item_type=?', [name, code]);
        b.rawInsert(
          'INSERT OR IGNORE INTO physical_descriptor_item_types(item_type,name) VALUES(?,?)',
          [code, name],
        );
      }

      void upsertHutPage(Batch b, int pageId, String name) {
        b.rawUpdate('UPDATE hid_usage_pages SET name=? WHERE page_id=?', [name, pageId]);
        b.rawInsert('INSERT OR IGNORE INTO hid_usage_pages(page_id,name) VALUES(?,?)', [pageId, name]);
      }

      void upsertHutUsage(Batch b, int pageId, int usageId, String name) {
        b.rawUpdate(
          'UPDATE hid_usages SET name=? WHERE page_id=? AND usage_id=?',
          [name, pageId, usageId],
        );
        b.rawInsert(
          'INSERT OR IGNORE INTO hid_usages(page_id,usage_id,name) VALUES(?,?,?)',
          [pageId, usageId, name],
        );
      }

      await db.transaction((txn) async {
        var batch = txn.batch();
        int ops = 0;

        Future<void> flush() async {
          if (ops == 0) return;
          await batch.commit(noResult: true);
          batch = txn.batch();
          ops = 0;
        }

        final stream = file.openRead().transform(utf8.decoder).transform(const LineSplitter());
        await for (final rawLine in stream) {
          final line = rawLine;

          if (line.startsWith('#')) {
            final vm = _reMetaVersion.firstMatch(line);
            if (vm != null) {
              meta.version = vm.group(1)?.trim();
              continue;
            }
            final dm = _reMetaDate.firstMatch(line);
            if (dm != null) {
              meta.date = dm.group(1)?.trim();
              continue;
            }
            continue;
          }

          if (line.trim().isEmpty) continue;

          /* Tagged records */
          final at = _reAT.firstMatch(line);
          if (at != null) {
            upsertAT(batch, _hexToInt(at.group(1)!), at.group(2)!.trim());
            ops += 2;
          } else {
            final hid = _reHidDesc.firstMatch(line);
            if (hid != null) {
              upsertHidDesc(batch, _hexToInt(hid.group(1)!), hid.group(2)!.trim());
              ops += 2;
            } else {
              final r = _reRItem.firstMatch(line);
              if (r != null) {
                upsertRItem(batch, _hexToInt(r.group(1)!), r.group(2)!.trim());
                ops += 2;
              } else {
                final bias = _reBias.firstMatch(line);
                if (bias != null) {
                  upsertBias(batch, int.parse(bias.group(1)!), bias.group(2)!.trim());
                  ops += 2;
                } else {
                  final phy = _rePhy.firstMatch(line);
                  if (phy != null) {
                    upsertPhy(batch, _hexToInt(phy.group(1)!), phy.group(2)!.trim());
                    ops += 2;
                  } else {
                    final hutPage = _reHutPage.firstMatch(line);
                    if (hutPage != null) {
                      final pageId = _hexToInt(hutPage.group(1)!);
                      currentHutPage = pageId;
                      upsertHutPage(batch, pageId, hutPage.group(2)!.trim());
                      ops += 2;
                    } else {
                      final cls = _reClass.firstMatch(line);
                      if (cls != null) {
                        final classId = _hexToInt(cls.group(1)!);
                        currentClass = classId;
                        currentSubclass = null;
                        upsertClass(batch, classId, cls.group(2)!.trim());
                        ops += 2;
                      } else {
                        /* Indentation-based parsing */
                        final t = _countLeadingTabs(line);
                        final tabs = t.tabs;
                        final rest = t.rest.trimRight();

                        /* HUT usages (tab=1 under HUT page) */
                        if (tabs == 1 && currentHutPage != null) {
                          final u = _reHutUsage.firstMatch(rest);
                          if (u != null) {
                            upsertHutUsage(batch, currentHutPage!, _hexToInt(u.group(1)!), u.group(2)!.trim());
                            ops += 2;
                          }
                        } else if (currentClass != null) {
                          /* Subclasses/protocols under a class section */
                          if (tabs == 1) {
                            final sc = _reSubclass.firstMatch(rest);
                            if (sc != null) {
                              currentSubclass = _hexToInt(sc.group(1)!);
                              upsertSubclass(batch, currentClass!, currentSubclass!, sc.group(2)!.trim());
                              ops += 2;
                            }
                          } else if (tabs == 2 && currentSubclass != null) {
                            final pr = _reProtocol.firstMatch(rest);
                            if (pr != null) {
                              upsertProtocol(
                                batch,
                                currentClass!,
                                currentSubclass!,
                                _hexToInt(pr.group(1)!),
                                pr.group(2)!.trim(),
                              );
                              ops += 2;
                            }
                          }
                        } else {
                          /* Vendor/device/interface block */
                          if (tabs == 0) {
                            final v = _reVendor.firstMatch(rest);
                            if (v != null) {
                              currentVid = _hexToInt(v.group(1)!);
                              currentPid = null;

                              /* Reset other contexts */
                              currentHutPage = null;
                              currentClass = null;
                              currentSubclass = null;

                              upsertVendor(batch, currentVid!, v.group(2)!.trim());
                              ops += 2;
                            }
                          } else if (tabs == 1 && currentVid != null) {
                            final d = _reDevice.firstMatch(rest);
                            if (d != null) {
                              currentPid = _hexToInt(d.group(1)!);
                              upsertProduct(batch, currentVid!, currentPid!, d.group(2)!.trim());
                              ops += 2;
                            }
                          } else if (tabs == 2 && currentVid != null && currentPid != null) {
                            final i = _reInterface.firstMatch(rest);
                            if (i != null) {
                              upsertInterface(
                                batch,
                                currentVid!,
                                currentPid!,
                                _hexToInt(i.group(1)!),
                                i.group(2)!.trim(),
                              );
                              ops += 2;
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          if (ops >= 2000) {
            await flush();
          }
        }

        /* meta */
        if (meta.version != null) {
          await upsertMeta(batch, 'version', meta.version!);
          ops += 2;
        }
        if (meta.date != null) {
          await upsertMeta(batch, 'date', meta.date!);
          ops += 2;
        }
        await upsertMeta(batch, 'source_format', 'usb.ids');
        ops += 2;
        await upsertMeta(batch, 'checksum_fnv64', checksumFnv64);
        ops += 2;

        await flush();
      });

      await db.execute('PRAGMA optimize;');
      return meta;
    } finally {
      await db.close();
    }
  }
}
