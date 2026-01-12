import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/theme/theme_mode_controller.dart';
import '../usb/providers.dart';
import 'usb_ids_db.dart';
import 'usb_ids_db_meta.dart';

final List<Uri> _usbIdsGzUris = <Uri>[
  Uri.parse('https://github.com/iodn/android-usb-device-info/releases/latest/download/usbids.sqlite.gz'),
  Uri.parse('https://github.com/iodn/android-usb-device-info/releases/download/v1.0.0/usbids.sqlite.gz'),
];

final List<Uri> _usbIdsShaUris = <Uri>[
  Uri.parse('https://github.com/iodn/android-usb-device-info/releases/latest/download/usbids.sqlite.gz.sha256'),
  Uri.parse('https://github.com/iodn/android-usb-device-info/releases/download/v1.0.0/usbids.sqlite.gz.sha256'),
];

const _kAutoCheckEnabled = 'usbids_auto_check_enabled_v3';
const _kLastCheckedAtIso = 'usbids_last_checked_at_iso_v3';
const _kUpdateAvailableHint = 'usbids_artifact_update_available_hint_v3';
const _kRemoteSha256 = 'usbids_artifact_remote_sha256_v3';
const _kInstalledSha256 = 'usbids_artifact_installed_sha256_v3';

enum UsbIdsUpdatePhase {
  idle,
  checking,
  downloading,
  decompressing,
  validating,
  installing,
  done,
  error,
}

class UsbIdsUpdateState {
  const UsbIdsUpdateState({
    required this.localMeta,
    required this.autoCheckEnabled,
    required this.updateAvailableHint,
    this.lastCheckedAt,
    this.phase = UsbIdsUpdatePhase.idle,
    this.progress,
    this.message,
    this.error,
    this.remoteSha256,
    this.installedSha256,
  });

  final UsbIdsDbMeta localMeta;
  final bool autoCheckEnabled;
  final bool updateAvailableHint;
  final DateTime? lastCheckedAt;

  final UsbIdsUpdatePhase phase;
  final double? progress;
  final String? message;
  final String? error;

  final String? remoteSha256;
  final String? installedSha256;

  bool get busy =>
      phase == UsbIdsUpdatePhase.checking ||
      phase == UsbIdsUpdatePhase.downloading ||
      phase == UsbIdsUpdatePhase.decompressing ||
      phase == UsbIdsUpdatePhase.validating ||
      phase == UsbIdsUpdatePhase.installing;

  static const Object _unset = Object();

  UsbIdsUpdateState copyWith({
    UsbIdsDbMeta? localMeta,
    bool? autoCheckEnabled,
    bool? updateAvailableHint,
    DateTime? lastCheckedAt,
    UsbIdsUpdatePhase? phase,
    Object? progress = _unset,
    Object? message = _unset,
    Object? error = _unset,
    String? remoteSha256,
    String? installedSha256,
  }) {
    return UsbIdsUpdateState(
      localMeta: localMeta ?? this.localMeta,
      autoCheckEnabled: autoCheckEnabled ?? this.autoCheckEnabled,
      updateAvailableHint: updateAvailableHint ?? this.updateAvailableHint,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      phase: phase ?? this.phase,
      progress: identical(progress, _unset) ? this.progress : (progress == null ? null : (progress as num).toDouble()),
      message: identical(message, _unset) ? this.message : message as String?,
      error: identical(error, _unset) ? this.error : error as String?,
      remoteSha256: remoteSha256 ?? this.remoteSha256,
      installedSha256: installedSha256 ?? this.installedSha256,
    );
  }
}

final usbIdsUpdateControllerProvider = AsyncNotifierProvider<UsbIdsUpdateController, UsbIdsUpdateState>(
  UsbIdsUpdateController.new,
);

final usbIdsAutoCheckCoordinatorProvider = Provider<void>((ref) {
  unawaited(ref.read(usbIdsUpdateControllerProvider.notifier).backgroundCheckIfDue());
});

class UsbIdsUpdateController extends AsyncNotifier<UsbIdsUpdateState> {
  @override
  Future<UsbIdsUpdateState> build() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);

    final auto = prefs.getBool(_kAutoCheckEnabled) ?? false;
    final hint = prefs.getBool(_kUpdateAvailableHint) ?? false;

    final lastIso = prefs.getString(_kLastCheckedAtIso);
    final last = DateTime.tryParse((lastIso ?? '').trim());

    final remoteSha = (prefs.getString(_kRemoteSha256) ?? '').trim().toLowerCase();
    final installedSha = (prefs.getString(_kInstalledSha256) ?? '').trim().toLowerCase();

    final db = await ref.read(usbIdsDbProvider.future);
    final meta = await db.readMeta();

    return UsbIdsUpdateState(
      localMeta: meta,
      autoCheckEnabled: auto,
      updateAvailableHint: hint,
      lastCheckedAt: last,
      phase: UsbIdsUpdatePhase.idle,
      remoteSha256: remoteSha.isEmpty ? null : remoteSha,
      installedSha256: installedSha.isEmpty ? null : installedSha,
    );
  }

  Future<void> setAutoCheckEnabled(bool v) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool(_kAutoCheckEnabled, v);

    final cur = state.value;
    if (cur != null) {
      state = AsyncValue.data(cur.copyWith(autoCheckEnabled: v));
    } else {
      state = AsyncValue.data(await build());
    }
  }

  Future<void> backgroundCheckIfDue() async {
    final cur = state.value ?? await build();
    if (!cur.autoCheckEnabled) return;

    final now = DateTime.now();
    final last = cur.lastCheckedAt;
    if (last != null && now.difference(last) < const Duration(days: 7)) return;

    final prefs = await ref.read(sharedPreferencesProvider.future);

    try {
      final client = HttpClient();
      try {
        final remoteSha = await _fetchRemoteSha256(client);
        if (remoteSha == null || remoteSha.isEmpty) return;

        final remoteLc = remoteSha.trim().toLowerCase();
        await prefs.setString(_kRemoteSha256, remoteLc);
        await prefs.setString(_kLastCheckedAtIso, now.toIso8601String());

        final installedLc = (prefs.getString(_kInstalledSha256) ?? '').trim().toLowerCase();
        final hint = installedLc.isEmpty ? true : installedLc != remoteLc;
        await prefs.setBool(_kUpdateAvailableHint, hint);

        if (!ref.mounted) return;

        try {
          final db = await ref.read(usbIdsDbProvider.future);
          final meta = await db.readMeta();
          state = AsyncValue.data(
            cur.copyWith(
              localMeta: meta,
              lastCheckedAt: now,
              updateAvailableHint: hint,
              remoteSha256: remoteLc,
              installedSha256: installedLc.isEmpty ? null : installedLc,
            ),
          );
        } catch (_) {
          state = AsyncValue.data(
            cur.copyWith(
              lastCheckedAt: now,
              updateAvailableHint: hint,
              remoteSha256: remoteLc,
              installedSha256: installedLc.isEmpty ? null : installedLc,
            ),
          );
        }
      } finally {
        client.close(force: true);
      }
    } catch (_) {}
  }

  Future<void> checkAndUpdateNow() async {
    final initial = state.value ?? await build();
    if (initial.busy) return;

    state = AsyncValue.data(
      initial.copyWith(
        phase: UsbIdsUpdatePhase.checking,
        message: 'Checking for updates…',
        progress: null,
        error: null,
      ),
    );

    final prefs = await ref.read(sharedPreferencesProvider.future);
    final now = DateTime.now();

    UsbIdsDb.beginUpdateGate();
    try {
      final installedSha0 = (prefs.getString(_kInstalledSha256) ?? '').trim().toLowerCase();
      final installedDbPath = await UsbIdsDb.resolvedDbPath(
        installedSha256: installedSha0.isEmpty ? null : installedSha0,
      );

      final dbDir = await getDatabasesPath();
      final tmpGzPath = p.join(dbDir, 'usbids.sqlite.gz.download');
      final tmpDbPath = p.join(dbDir, 'usbids.new.sqlite');

      final client = HttpClient();
      try {
        final remoteSha = await _fetchRemoteSha256(client);
        if (remoteSha == null || remoteSha.isEmpty) {
          throw StateError('Failed to fetch usbids.sqlite.gz.sha256 from GitHub.');
        }

        final remoteShaLc = remoteSha.trim().toLowerCase();
        await prefs.setString(_kRemoteSha256, remoteShaLc);

        final s0 = state.value ?? initial;
        state = AsyncValue.data(s0.copyWith(remoteSha256: remoteShaLc));

        final installedSha = (prefs.getString(_kInstalledSha256) ?? '').trim().toLowerCase();
        await prefs.setString(_kLastCheckedAtIso, now.toIso8601String());

        if (installedSha.isNotEmpty && installedSha == remoteShaLc) {
          await prefs.setBool(_kUpdateAvailableHint, false);
          final meta = await _safeReadMeta(installedDbPath, fallback: initial.localMeta);

          state = AsyncValue.data(
            initial.copyWith(
              localMeta: meta,
              lastCheckedAt: now,
              updateAvailableHint: false,
              phase: UsbIdsUpdatePhase.done,
              message: 'Already up to date.',
              progress: null,
              error: null,
              remoteSha256: remoteShaLc,
              installedSha256: installedSha,
            ),
          );
          return;
        }

        state = AsyncValue.data(
          (state.value ?? initial).copyWith(
            phase: UsbIdsUpdatePhase.downloading,
            message: 'Downloading usbids.sqlite.gz…',
            progress: 0.0,
            error: null,
          ),
        );

        final tmpGz = File(tmpGzPath);
        if (await tmpGz.exists()) {
          try {
            await tmpGz.delete();
          } catch (_) {}
        }

        Uri? matchedUri;
        String? lastComputed;

        for (var i = 0; i < _usbIdsGzUris.length; i++) {
          final rawUri = _usbIdsGzUris[i];
          final uri = _withCacheBust(rawUri);

          final cur = state.value ?? initial;
          state = AsyncValue.data(
            cur.copyWith(
              message: 'Downloading usbids.sqlite.gz… (${i + 1}/${_usbIdsGzUris.length})',
              progress: 0.0,
            ),
          );

          final resp = await _getBinaryResponse(client, uri);
          if (resp == null) continue;
          if (resp.statusCode != HttpStatus.ok) {
            await resp.drain();
            continue;
          }

          final total = resp.contentLength;
          int received = 0;

          if (await tmpGz.exists()) {
            try {
              await tmpGz.delete();
            } catch (_) {}
          }

          final sink = tmpGz.openWrite();
          final sha = _Sha256();
          try {
            await for (final chunk in resp) {
              sink.add(chunk);
              sha.add(chunk);
              received += chunk.length;

              final st = state.value;
              if (st != null && st.phase == UsbIdsUpdatePhase.downloading) {
                final prog = (total > 0) ? (received / total).clamp(0.0, 1.0) : null;
                state = AsyncValue.data(st.copyWith(progress: prog));
              }
            }
          } finally {
            await sink.flush();
            await sink.close();
          }

          final computedSha = sha.closeHex().toLowerCase();
          lastComputed = computedSha;
          if (computedSha == remoteShaLc) {
            matchedUri = rawUri;
            break;
          }

          try {
            if (await tmpGz.exists()) await tmpGz.delete();
          } catch (_) {}
        }

        if (matchedUri == null) {
          throw StateError(
            'SHA-256 mismatch for usbids.sqlite.gz.\n'
            'Expected: $remoteShaLc\n'
            'Got (last): ${lastComputed ?? '(none)'}\n'
            'Tried mirrors: ${_usbIdsGzUris.length}',
          );
        }

        state = AsyncValue.data(
          (state.value ?? initial).copyWith(
            phase: UsbIdsUpdatePhase.decompressing,
            message: 'Decompressing database…',
            progress: null,
            error: null,
          ),
        );

        await deleteDatabase(tmpDbPath);
        await _gunzipToFile(srcGz: tmpGz, dst: File(tmpDbPath));

        state = AsyncValue.data(
          (state.value ?? initial).copyWith(
            phase: UsbIdsUpdatePhase.validating,
            message: 'Validating database…',
            progress: null,
            error: null,
          ),
        );

        await _validateSqliteDb(tmpDbPath);

        final remoteMeta = await _readMetaFromPath(tmpDbPath);

        final localChecksum = (initial.localMeta.checksumFnv64 ?? '').trim().toUpperCase();
        final remoteChecksum = (remoteMeta.checksumFnv64 ?? '').trim().toUpperCase();
        final sameDb = localChecksum.isNotEmpty && remoteChecksum.isNotEmpty && localChecksum == remoteChecksum;

        if (sameDb) {
          await prefs.setString(_kInstalledSha256, remoteShaLc);
          await prefs.setBool(_kUpdateAvailableHint, false);

          try {
            await tmpGz.delete();
          } catch (_) {}
          try {
            await File(tmpDbPath).delete();
          } catch (_) {}

          ref.invalidate(usbIdsDbProvider);
          ref.invalidate(usbRepositoryProvider);

          state = AsyncValue.data(
            initial.copyWith(
              localMeta: initial.localMeta,
              lastCheckedAt: now,
              updateAvailableHint: false,
              phase: UsbIdsUpdatePhase.done,
              message: 'Already up to date.',
              progress: null,
              error: null,
              remoteSha256: remoteShaLc,
              installedSha256: remoteShaLc,
            ),
          );
          return;
        }

        state = AsyncValue.data(
          (state.value ?? initial).copyWith(
            phase: UsbIdsUpdatePhase.installing,
            message: 'Installing update…',
            progress: null,
            error: null,
          ),
        );

        final targetDbPath = await UsbIdsDb.resolvedDbPath(installedSha256: remoteShaLc);
        await _deleteSidecars(targetDbPath);

        final target = File(targetDbPath);
        if (await target.exists()) {
          try {
            await target.delete();
          } catch (_) {}
          await _deleteSidecars(targetDbPath);
        }

        await File(tmpDbPath).rename(targetDbPath);

        try {
          await tmpGz.delete();
        } catch (_) {}

        await prefs.setString(_kInstalledSha256, remoteShaLc);
        await prefs.setBool(_kUpdateAvailableHint, false);

        ref.invalidate(usbIdsDbProvider);
        ref.invalidate(usbRepositoryProvider);

        final meta = await _safeReadMeta(targetDbPath, fallback: remoteMeta);

        state = AsyncValue.data(
          initial.copyWith(
            localMeta: meta,
            lastCheckedAt: now,
            updateAvailableHint: false,
            phase: UsbIdsUpdatePhase.done,
            message: 'Database updated.',
            progress: null,
            error: null,
            remoteSha256: remoteShaLc,
            installedSha256: remoteShaLc,
          ),
        );
      } finally {
        client.close(force: true);
      }
    } catch (e) {
      ref.invalidate(usbIdsDbProvider);
      ref.invalidate(usbRepositoryProvider);

      final cur = state.value ?? initial;
      state = AsyncValue.data(
        cur.copyWith(
          phase: UsbIdsUpdatePhase.error,
          error: e.toString(),
          message: 'Update failed.',
          progress: null,
        ),
      );
    } finally {
      UsbIdsDb.endUpdateGate();
    }
  }

  Future<UsbIdsDbMeta> _safeReadMeta(String path, {required UsbIdsDbMeta fallback}) async {
    try {
      final f = File(path);
      if (!await f.exists()) return fallback;
      return await _readMetaFromPath(path);
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _deleteSidecars(String dbPath) async {
    final candidates = <String>[
      '$dbPath-wal',
      '$dbPath-shm',
      '$dbPath-journal',
    ];
    for (final p0 in candidates) {
      try {
        final f = File(p0);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
  }

  Future<String?> _fetchRemoteSha256(HttpClient client) async {
    for (final rawUri in _usbIdsShaUris) {
      final uri = _withCacheBust(rawUri);
      try {
        final req = await client.getUrl(uri);
        req.followRedirects = true;
        req.maxRedirects = 8;
        req.headers.set(HttpHeaders.acceptHeader, 'text/plain,*/*');
        req.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
        req.headers.set(HttpHeaders.userAgentHeader, 'usbdevinfo/1.0');

        final resp = await req.close();
        if (resp.statusCode != HttpStatus.ok) {
          await resp.drain();
          continue;
        }

        final body = await resp.transform(utf8.decoder).join();
        final sha = _parseSha256File(body);
        if (sha != null && sha.isNotEmpty) return sha;
      } catch (_) {}
    }
    return null;
  }

  Future<HttpClientResponse?> _getBinaryResponse(HttpClient client, Uri uri) async {
    try {
      final req = await client.getUrl(uri);
      req.followRedirects = true;
      req.maxRedirects = 8;
      req.headers.set(HttpHeaders.acceptHeader, 'application/octet-stream,*/*');
      req.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
      req.headers.set(HttpHeaders.userAgentHeader, 'usbdevinfo/1.0');
      final resp = await req.close();
      return resp;
    } catch (_) {
      return null;
    }
  }

  static Uri _withCacheBust(Uri uri) {
    final qp = Map<String, String>.from(uri.queryParameters);
    qp['t'] = DateTime.now().millisecondsSinceEpoch.toString();
    return uri.replace(queryParameters: qp);
  }

  static String? _parseSha256File(String text) {
    final lines = const LineSplitter().convert(text);
    final re = RegExp(r'([0-9a-fA-F]{64})');
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#')) continue;
      final m = re.firstMatch(line);
      if (m != null) return m.group(1)!.toLowerCase();
    }
    return null;
  }

  Future<void> _gunzipToFile({required File srcGz, required File dst}) async {
    if (await dst.exists()) {
      try {
        await dst.delete();
      } catch (_) {}
    }
    await dst.parent.create(recursive: true);

    final out = dst.openWrite();
    try {
      await srcGz.openRead().transform(gzip.decoder).pipe(out);
    } finally {
      await out.flush();
      await out.close();
    }
  }

  Future<void> _validateSqliteDb(String path) async {
    final f = File(path);
    if (!await f.exists()) {
      throw StateError('Decompressed DB file does not exist.');
    }

    final len = await f.length();
    if (len < 4096) {
      throw StateError('Decompressed DB is too small ($len bytes).');
    }

    final raf = await f.open(mode: FileMode.read);
    try {
      final head = await raf.read(16);
      final sig = String.fromCharCodes(head);
      if (!sig.startsWith('SQLite format 3\u0000')) {
        throw StateError('Downloaded file is not a valid SQLite database.');
      }
    } finally {
      await raf.close();
    }

    final db = await openDatabase(path, readOnly: true);
    try {
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('meta','vendors','products','usb_classes');",
      );
      final names = tables.map((r) => (r['name'] as String?) ?? '').toSet();
      const required = {'meta', 'vendors', 'products', 'usb_classes'};
      if (!names.containsAll(required)) {
        throw StateError('Downloaded DB is missing required tables: $required');
      }

      final qc = await db.rawQuery('PRAGMA quick_check;');
      final msg = (qc.isNotEmpty ? (qc.first.values.first?.toString() ?? '') : '').trim();
      if (msg.toLowerCase() != 'ok') {
        throw StateError('SQLite integrity check failed: $msg');
      }
    } finally {
      await db.close();
    }
  }

  Future<UsbIdsDbMeta> _readMetaFromPath(String path) async {
    final db = await openDatabase(path, readOnly: true);
    try {
      final rows = await db.query('meta', columns: ['key', 'value']);
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
    } finally {
      await db.close();
    }
  }
}

class _Sha256 {
  _Sha256() {
    _h0 = 0x6a09e667;
    _h1 = 0xbb67ae85;
    _h2 = 0x3c6ef372;
    _h3 = 0xa54ff53a;
    _h4 = 0x510e527f;
    _h5 = 0x9b05688c;
    _h6 = 0x1f83d9ab;
    _h7 = 0x5be0cd19;
  }

  late int _h0, _h1, _h2, _h3, _h4, _h5, _h6, _h7;

  final Uint8List _buffer = Uint8List(64);
  int _bufferLen = 0;

  int _lengthHi = 0;
  int _lengthLo = 0;

  void add(List<int> data) {
    var i = 0;

    final bits = data.length * 8;
    _lengthLo = (_lengthLo + bits) & 0xffffffff;
    if (_lengthLo < bits) {
      _lengthHi = (_lengthHi + 1) & 0xffffffff;
    }

    while (i < data.length) {
      final space = 64 - _bufferLen;
      final take = (data.length - i < space) ? (data.length - i) : space;
      _buffer.setRange(_bufferLen, _bufferLen + take, data, i);
      _bufferLen += take;
      i += take;

      if (_bufferLen == 64) {
        _compress(_buffer);
        _bufferLen = 0;
      }
    }
  }

  String closeHex() {
    final origHi = _lengthHi;
    final origLo = _lengthLo;

    final pad = <int>[0x80];
    final mod = _bufferLen;
    final padLen = (mod < 56) ? (56 - mod) : (56 + (64 - mod));
    pad.addAll(List<int>.filled(padLen - 1, 0));
    add(pad);

    final lenBytes = Uint8List(8);
    _writeUint32BE(lenBytes, 0, origHi);
    _writeUint32BE(lenBytes, 4, origLo);
    add(lenBytes);

    final out = Uint8List(32);
    _writeUint32BE(out, 0, _h0);
    _writeUint32BE(out, 4, _h1);
    _writeUint32BE(out, 8, _h2);
    _writeUint32BE(out, 12, _h3);
    _writeUint32BE(out, 16, _h4);
    _writeUint32BE(out, 20, _h5);
    _writeUint32BE(out, 24, _h6);
    _writeUint32BE(out, 28, _h7);

    final sb = StringBuffer();
    for (final b in out) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  void _compress(Uint8List chunk) {
    final w = Uint32List(64);
    for (var i = 0; i < 16; i++) {
      w[i] = _readUint32BE(chunk, i * 4);
    }
    for (var i = 16; i < 64; i++) {
      final s0 = _rotr(w[i - 15], 7) ^ _rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
      final s1 = _rotr(w[i - 2], 17) ^ _rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
      w[i] = (w[i - 16] + s0 + w[i - 7] + s1) & 0xffffffff;
    }

    var a = _h0;
    var b = _h1;
    var c = _h2;
    var d = _h3;
    var e = _h4;
    var f = _h5;
    var g = _h6;
    var h = _h7;

    for (var i = 0; i < 64; i++) {
      final S1 = _rotr(e, 6) ^ _rotr(e, 11) ^ _rotr(e, 25);
      final ch = (e & f) ^ ((~e) & g);
      final temp1 = (h + S1 + ch + _k[i] + w[i]) & 0xffffffff;
      final S0 = _rotr(a, 2) ^ _rotr(a, 13) ^ _rotr(a, 22);
      final maj = (a & b) ^ (a & c) ^ (b & c);
      final temp2 = (S0 + maj) & 0xffffffff;

      h = g;
      g = f;
      f = e;
      e = (d + temp1) & 0xffffffff;
      d = c;
      c = b;
      b = a;
      a = (temp1 + temp2) & 0xffffffff;
    }

    _h0 = (_h0 + a) & 0xffffffff;
    _h1 = (_h1 + b) & 0xffffffff;
    _h2 = (_h2 + c) & 0xffffffff;
    _h3 = (_h3 + d) & 0xffffffff;
    _h4 = (_h4 + e) & 0xffffffff;
    _h5 = (_h5 + f) & 0xffffffff;
    _h6 = (_h6 + g) & 0xffffffff;
    _h7 = (_h7 + h) & 0xffffffff;
  }

  static int _rotr(int x, int n) => ((x >> n) | (x << (32 - n))) & 0xffffffff;

  static int _readUint32BE(Uint8List b, int o) {
    return ((b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | (b[o + 3])) & 0xffffffff;
  }

  static void _writeUint32BE(Uint8List b, int o, int v) {
    b[o] = (v >> 24) & 0xff;
    b[o + 1] = (v >> 16) & 0xff;
    b[o + 2] = (v >> 8) & 0xff;
    b[o + 3] = v & 0xff;
  }

  static const List<int> _k = <int>[
    0x428a2f98,
    0x71374491,
    0xb5c0fbcf,
    0xe9b5dba5,
    0x3956c25b,
    0x59f111f1,
    0x923f82a4,
    0xab1c5ed5,
    0xd807aa98,
    0x12835b01,
    0x243185be,
    0x550c7dc3,
    0x72be5d74,
    0x80deb1fe,
    0x9bdc06a7,
    0xc19bf174,
    0xe49b69c1,
    0xefbe4786,
    0x0fc19dc6,
    0x240ca1cc,
    0x2de92c6f,
    0x4a7484aa,
    0x5cb0a9dc,
    0x76f988da,
    0x983e5152,
    0xa831c66d,
    0xb00327c8,
    0xbf597fc7,
    0xc6e00bf3,
    0xd5a79147,
    0x06ca6351,
    0x14292967,
    0x27b70a85,
    0x2e1b2138,
    0x4d2c6dfc,
    0x53380d13,
    0x650a7354,
    0x766a0abb,
    0x81c2c92e,
    0x92722c85,
    0xa2bfe8a1,
    0xa81a664b,
    0xc24b8b70,
    0xc76c51a3,
    0xd192e819,
    0xd6990624,
    0xf40e3585,
    0x106aa070,
    0x19a4c116,
    0x1e376c08,
    0x2748774c,
    0x34b0bcb5,
    0x391c0cb3,
    0x4ed8aa4a,
    0x5b9cca4f,
    0x682e6ff3,
    0x748f82ee,
    0x78a5636f,
    0x84c87814,
    0x8cc70208,
    0x90befffa,
    0xa4506ceb,
    0xbef9a3f7,
    0xc67178f2,
  ];
}
