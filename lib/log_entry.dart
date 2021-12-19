import 'package:logecom/log_level.dart';

class LogEntry {
  LogEntry({
    required this.category,
    required this.message,
    this.level = LogLevel.log,
    this.context = const [],
  });

  /// Use [LogLevel] class static members to get standard predefined
  /// log levels
  final String level;

  /// The source of log entry
  final String category;

  /// Printable message text
  final String message;

  /// Any context objects connected to entry.
  /// Formatting depends on middleware used.
  final List<dynamic> context;
}
