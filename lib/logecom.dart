library logecom;

export 'translator/console_transport.dart';
export 'translator/http_formatter.dart';
export 'translator/http_log_entry.dart';
export 'translator/string_mapper.dart';
export 'log_level.dart';
export 'log_translator.dart';
export 'logger.dart';

import 'package:logecom/log_entry.dart';
import 'package:logecom/logger.dart';
import 'log_translator.dart';

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
  static final instance = Logecom();

  /// Create Logger instance for specified category.
  /// Common pattern is to use class name as a category specifier:
  ///
  /// `private readonly logger = Logecom.createLogger('CategoryOrClassName');`
  ///
  /// or even simply this way:
  ///
  /// `private readonly logger = Logecom.createLogger(this);`
  ///
  /// If no category passed, the `Global` name will be used.
  ///
  static Logger createLogger(dynamic category) {
    if (category is String) return Logger(category, instance);
    if (category is Type) return Logger(category.toString(), instance);
    return Logger(category.runtimeType.toString(), instance);
  }

  /// Configure default Logecom instance.
  /// For the global logging system it's ok to use Singleton pattern ;)
  ///
  /// To prevent possible duplicates during re-configuration by mistake,
  /// this method always configure default Logecom instance "from scratch",
  /// removing all existing middleware.
  ///
  static Logecom configure() {
    instance._pipe = [];
    return instance;
  }

  Logecom use(LogTranslator translator) {
    _pipe.add(translator);
    return this;
  }

  @override
  void translate(LogEntry entry, LogTranslatorNextFunction? next) {
    if (_pipe.isEmpty) return;
    _getNextFunction(0)(entry);
  }

  List<LogTranslator> _pipe = [];

  LogTranslatorNextFunction _getNextFunction(int i) {
    return (LogEntry entry) {
      if (i >= _pipe.length) return;
      _pipe[i].translate(entry, _getNextFunction(i + 1));
    };
  }
}
