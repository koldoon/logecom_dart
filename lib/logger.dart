import 'package:logecom/log_entry.dart';
import 'logecom.dart';

///  Conventional logger fluent API interface
class Logger {
  Logger(String category, Logecom logecom)
      : _category = category,
        _logecom = logecom;

  final String _category;
  final Logecom _logecom;

  Logger _createRecord(String level, String message, [dynamic context]) {
    final ctx = [];
    if (context is List) {
      ctx.addAll(context);
    } else if (context != null) {
      ctx.add(context);
    }
    _logecom.translate(
      LogEntry(
        category: _category,
        message: message,
        level: level,
        context: ctx,
      ),
      null,
    );
    return this;
  }

  Logger log(String message, [dynamic context]) {
    return _createRecord(LogLevel.log, message, context);
  }

  Logger debug(String message, [dynamic context]) {
    return _createRecord(LogLevel.debug, message, context);
  }

  Logger info(String message, [dynamic context]) {
    return _createRecord(LogLevel.info, message, context);
  }

  Logger warn(String message, [dynamic context]) {
    return _createRecord(LogLevel.warn, message, context);
  }

  Logger error(String message, [dynamic context]) {
    return _createRecord(LogLevel.error, message, context);
  }

  Logger fatal(String message, [dynamic context]) {
    return _createRecord(LogLevel.fatal, message, context);
  }
}
