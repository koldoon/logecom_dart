library logecom;

import 'package:logecom/log_entry.dart';
import 'package:logecom/logger.dart';

import 'log_translator.dart';

export 'log_level.dart';
export 'log_translator.dart';
export 'logger.dart';
export 'translator/console_transport.dart';
export 'translator/http_formatter.dart';
export 'translator/http_log_entry.dart';
export 'translator/string_mapper.dart';

/// Simple but powerful middleware-based Logging system inspired by
/// Nodejs Express http library.
///
/// Motivation:
/// There are many logging libraries present with different
/// approaches and interfaces. If you want to migrate from one logger to
/// another, you must refactor lots of entry points in your application where
/// particular logger is initialized or used.
///
/// The idea is to abstract from logging process as much as possible and
/// to define simple common interface with minimal overhead and give a
/// stack to implement any logging pipeline with desired functionality in single
/// place.
///
/// There is basically the only interface introduced for any log processing:
/// [LogTranslator]
///
/// By implementing it in different ways it is possible to achieve any
/// result. You can transform, format, collect, print or send, and even
/// use another logger! - anything you want inside this pipeline.
///
/// Implementing [LogTranslator] by [Logecom] itself makes it possible to
/// create complex logs translation logic when one logger pipeline can be applied
/// up to another (conditionally, for example) if needed ;)
///
class Logecom implements LogTranslator {
  static Logecom? _instance;
  static Logecom get instance => _instance ??= Logecom();

  /// Create Logger instance for specified category.
  /// Common pattern is to use class name as a category specifier:
  ///
  ///   `private readonly logger = Logecom.createLogger('CategoryOrClassName');`
  ///
  /// or even simply this way:
  ///
  ///   `private readonly logger = Logecom.createLogger(ClassName);`
  ///
  static Logger createLogger(dynamic category) {
    if (category is String) return Logger(category, instance);
    if (category is Type) return Logger(category.toString(), instance);
    return Logger(category.runtimeType.toString(), instance);
  }

  @override
  void translate(LogEntry entry, LogTranslatorNextFunction? next) {
    if (pipeline.isEmpty) return;
    _getNextFunction(0)(entry);
  }

  List<LogTranslator> pipeline = [];

  LogTranslatorNextFunction _getNextFunction(int i) {
    return (LogEntry entry) {
      if (i >= pipeline.length) return;
      pipeline[i].translate(entry, _getNextFunction(i + 1));
    };
  }
}
