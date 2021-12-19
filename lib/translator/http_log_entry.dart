class HttpLogContext {
  HttpLogContext({
    required this.method,
    required this.url,
    required this.statusCode,
    required this.statusMessage,
    required this.duration,
    this.headers,
    this.responseData,
    this.requestData,
  });

  int statusCode;
  String statusMessage;
  Duration duration;
  String method;
  Uri url;
  Map<String, String>? headers;
  dynamic requestData;
  dynamic responseData;
}
