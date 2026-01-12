class Fnv1a64 {
  static const int _offsetBasis = 0xcbf29ce484222325;
  static const int _prime = 0x100000001b3;

  int _hash = _offsetBasis;

  void addBytes(List<int> bytes) {
    for (final b in bytes) {
      _hash ^= (b & 0xff);
      _hash = (_hash * _prime) & 0xFFFFFFFFFFFFFFFF;
    }
  }

  String digestHex() => _hash.toRadixString(16).padLeft(16, '0');
}
