class ApiException implements Exception {
  final String message;
  final Map<String, dynamic> data;

  ApiException(this.message, this.data);

  @override
  String toString() => message;
}

