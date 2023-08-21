
class Contradiction implements Exception {
  final String message;

  Contradiction(this.message);

  @override
  String toString() => "Contradiction: $message";
}
