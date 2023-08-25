
class Contradiction implements Exception {
  final String message;

  const Contradiction(this.message);

  @override
  String toString() => "Contradiction: $message";
}
