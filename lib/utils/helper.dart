class FlutterException implements Exception {
  const FlutterException({
    required this.exception,
  });
  final String exception;
  @override
  String toString() {
    return exception.toString();
  }
}
