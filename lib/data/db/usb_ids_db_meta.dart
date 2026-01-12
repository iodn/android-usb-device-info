import 'package:meta/meta.dart';

@immutable
class UsbIdsDbMeta {
  const UsbIdsDbMeta({this.version, this.date, this.checksumFnv64});

  final String? version;
  final String? date;
  final String? checksumFnv64;

  String get versionLabel => (version == null || version!.trim().isEmpty) ? '—' : version!.trim();
  String get dateLabel => (date == null || date!.trim().isEmpty) ? '—' : date!.trim();
  String get checksumLabel =>
      (checksumFnv64 == null || checksumFnv64!.trim().isEmpty) ? '—' : checksumFnv64!.trim();
}
