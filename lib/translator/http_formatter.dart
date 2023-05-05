import 'dart:convert';
import 'dart:io';

import 'package:duration/duration.dart';
import 'package:logecom/log_entry.dart';
import 'package:logecom/log_translator.dart';
import 'package:logecom/painter.dart';
import 'package:logecom/translator/http_log_entry.dart';
import 'package:logecom/translator/string_mapper.dart';

/// Formats log entries with [HttpLogContext] inside.
///
///  * [printRpcContent] Try to format and print [responseData] and [requestData] available
///    in [HttpLogContext] object. If you are not interested in specific data but want to see
///    registered events - set to `false`
///  * [colorize] Use special ANSI sequences for colorful output. Warning: not all consoles support
///    this feature. For example, XCode debug console will print this sequences "as is" so the output
///    will be "dirty". Use with care.
///  * [hideAuthData] If `true`, will parse the headers provided and avoid printing the content of
///    `Authorization` header.
class HttpFormatter implements LogTranslator {
  HttpFormatter({
    LogecomTextPainter textPainter = const UtfPainter(),
    this.printRpcContent = false,
    this.hideAuthData = true,
  }) {
    _gp = textPainter.gray;
    _gp2 = textPainter.white;
    _rsp = textPainter.yellow;
    _erp = textPainter.red;
  }

  final bool printRpcContent;
  final bool hideAuthData;

  final _encoder = const JsonEncoder();
  StringMapper _gp = dummyStringMapper; // gray painter
  StringMapper _gp2 = dummyStringMapper; // gray painter 2
  StringMapper _rsp = dummyStringMapper; // "response painter"
  StringMapper _erp = dummyStringMapper; // "error painter"

  @override
  void translate(LogEntry entry, LogTranslatorNextFunction? next) {
    if (entry.context.isNotEmpty && entry.context.first is! HttpLogContext ||
        entry.context.isEmpty ||
        next == null) {
      if (next != null) next(entry);
      return;
    }

    final HttpLogContext log = entry.context.first;

    var params = '';
    var response = '';
    var request = '';
    var headers = '';

    if (printRpcContent) {
      params = _encoder.convert(log.url.queryParameters);

      if (log.responseData != null) {
        try {
          response = _encoder.convert(log.responseData);
        } catch (err) {
          response = log.responseData.toString();
        }
      }

      if (log.requestData != null) {
        try {
          request = _encoder.convert(log.requestData);
        } catch (err) {
          request = log.requestData.toString();
        }
      }

      if (log.headers != null) {
        final headersCopy = Map.fromEntries(log.headers!.entries);
        if (headersCopy.containsKey(HttpHeaders.authorizationHeader) && hideAuthData) {
          headersCopy[HttpHeaders.authorizationHeader] = '<hidden>';
        }
        try {
          headers = _encoder.convert(headersCopy);
        } catch (err) {
          headers = headersCopy.toString();
        }
      }
    }

    var responseDataLength = '';
    if (log.responseData is List) {
      responseDataLength = 'List ${(log.responseData as List).length} items';
    } else if (log.responseData is Map) {
      responseDataLength = 'Object ${(log.responseData as Map).length} fields';
    } else if (log.responseData is String) {
      responseDataLength = 'String ${(log.responseData as String).length} chars';
    }

    final line = [
      '${log.method} ',
      '${log.url.path} ',
      log.statusCode > 0 && log.statusCode < 500
          ? '${_rsp('→ ${log.statusCode}')} '
          : '${_erp('→ ${log.statusCode} (${log.statusMessage})')} ',
      '${_gp('[${prettyDuration(log.duration, abbreviated: true, tersity: DurationTersity.millisecond)}]')} ',
      if (responseDataLength.isNotEmpty) '${_gp('{$responseDataLength}')} ',
      if (request.isNotEmpty || response.isNotEmpty || headers.isNotEmpty || params.isNotEmpty) '\n',
      if (printRpcContent) ...[_gp2('  Base URL: '), _gp(log.url.host), '\n'],
      if (printRpcContent && log.url.queryParameters.isNotEmpty) ...[_gp2('  Params: '), _gp(params), '\n'],
      if (headers.isNotEmpty) ...[_gp2('  Headers: '), _gp(headers), '\n'],
      if (request.isNotEmpty) ...[_gp2('  Request Data: '), _gp(request), '\n'],
      if (response.isNotEmpty) ...[_gp2('  Response Data: '), _gp(response), '\n'],
    ];

    next(LogEntry(category: entry.category, message: line.join()));
  }
}
