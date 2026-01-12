import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'usb_ids_db_meta.dart';

class UsbIdsDb {
  UsbIdsDb._(this._db);

  final Database _db;

  final Map<int, String> _vendorCache = {};
  final Map<String, String> _productCache = {};
  final Map<int, String> _classCache = {};
  final Map<String, String> _subclassCache = {};
  final Map<String, String> _protocolCache = {};


  static Completer<void>? _updateGate;

  static void beginUpdateGate() {
    if (_updateGate != null) return;
    _updateGate = Completer<void>();
  }

  static void endUpdateGate() {
    final gate = _updateGate;
    _updateGate = null;
    if (gate != null && !gate.isCompleted) {
      gate.complete();
    }
  }

  static Future<void> _waitForUpdateIfNeeded() async {
    final gate = _updateGate;
    if (gate != null) {
      await gate.future;
    }
  }

  static String _fileNameForSha(String? sha256) {
    final s = (sha256 ?? '').trim().toLowerCase();
    if (s.isEmpty) return 'usbids.sqlite';
    final short = s.length >= 8 ? s.substring(0, 8) : s;
    return 'usbids_$short.sqlite';
  }

  static Future<String> resolvedDbPath({String? installedSha256}) async {
    final dbPath = await getDatabasesPath();
    return p.join(dbPath, _fileNameForSha(installedSha256));
  }

  static Future<UsbIdsDb> open({String? installedSha256}) async {
    await _waitForUpdateIfNeeded();

    final outPath = await resolvedDbPath(installedSha256: installedSha256);
    final exists = await databaseExists(outPath);

    if (!exists) {
      final parent = Directory(p.dirname(outPath));
      await parent.create(recursive: true);

      final data = await rootBundle.load('assets/db/usbids.sqlite');
      final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      await File(outPath).writeAsBytes(bytes, flush: true);
    } else {
      try {
        final f = File(outPath);
        if (await f.length() < 100) {
          final data = await rootBundle.load('assets/db/usbids.sqlite');
          final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await f.writeAsBytes(bytes, flush: true);
        }
      } catch (_) {
        // ignore; openDatabase will surface errors if any
      }
    }

    final db = await openDatabase(outPath, readOnly: true);
    return UsbIdsDb._(db);
  }

  Future<UsbIdsDbMeta> readMeta() async {
    try {
      final rows = await _db.query('meta', columns: ['key', 'value']);
      String? version;
      String? date;
      String? checksum;

      for (final r in rows) {
        final k = r['key'] as String?;
        final v = r['value'] as String?;
        if (k == null) continue;

        switch (k) {
          case 'version':
            version = v;
            break;
          case 'date':
            date = v;
            break;
          case 'checksum_fnv64':
            checksum = v;
            break;
        }
      }

      return UsbIdsDbMeta(version: version, date: date, checksumFnv64: checksum);
    } catch (_) {
      return const UsbIdsDbMeta();
    }
  }

  Future<String?> vendorName(int vid) async {
    if (_vendorCache.containsKey(vid)) return _vendorCache[vid];
    final rows = await _db.query(
      'vendors',
      columns: ['name'],
      where: 'vid = ?',
      whereArgs: [vid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final name = rows.first['name'] as String?;
    if (name != null) _vendorCache[vid] = name;
    return name;
  }

  Future<String?> productName(int vid, int pid) async {
    final key = '$vid:$pid';
    if (_productCache.containsKey(key)) return _productCache[key];
    final rows = await _db.query(
      'products',
      columns: ['name'],
      where: 'vid = ? AND pid = ?',
      whereArgs: [vid, pid],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final name = rows.first['name'] as String?;
    if (name != null) _productCache[key] = name;
    return name;
  }

  Future<String?> usbClassName(int classId) async {
    if (_classCache.containsKey(classId)) return _classCache[classId];
    final rows = await _db.query(
      'usb_classes',
      columns: ['name'],
      where: 'class_id = ?',
      whereArgs: [classId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final name = rows.first['name'] as String?;
    if (name != null) _classCache[classId] = name;
    return name;
  }

  Future<String?> usbSubclassName(int classId, int subclassId) async {
    final key = '$classId:$subclassId';
    if (_subclassCache.containsKey(key)) return _subclassCache[key];
    final rows = await _db.query(
      'usb_subclasses',
      columns: ['name'],
      where: 'class_id = ? AND subclass_id = ?',
      whereArgs: [classId, subclassId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final name = rows.first['name'] as String?;
    if (name != null) _subclassCache[key] = name;
    return name;
  }

  Future<String?> usbProtocolName(int classId, int subclassId, int protocolId) async {
    final key = '$classId:$subclassId:$protocolId';
    if (_protocolCache.containsKey(key)) return _protocolCache[key];
    final rows = await _db.query(
      'usb_protocols',
      columns: ['name'],
      where: 'class_id = ? AND subclass_id = ? AND protocol_id = ?',
      whereArgs: [classId, subclassId, protocolId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final name = rows.first['name'] as String?;
    if (name != null) _protocolCache[key] = name;
    return name;
  }

  Future<void> close() => _db.close();
}
