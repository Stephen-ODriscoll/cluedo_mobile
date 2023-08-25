
class Contradiction implements Exception {
  final String _message;

  const Contradiction(this._message);

  @override
  String toString() => _message;
}
