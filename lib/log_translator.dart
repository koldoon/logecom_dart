import 'package:logecom/log_entry.dart';

typedef LogTranslatorNextFunction = void Function(LogEntry entry);

/// Abstract Log translator definition
abstract class LogTranslator {
  void translate(LogEntry entry, LogTranslatorNextFunction? next);
}
