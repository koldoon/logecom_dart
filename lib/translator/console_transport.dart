import 'dart:developer' as developer;
import 'dart:io';
import 'dart:math';

import 'package:duration/duration.dart';
import 'package:intl/intl.dart';
import 'package:logecom/ansi_painter.dart';
import 'package:logecom/log_entry.dart';
import 'package:logecom/log_level.dart';
import 'package:logecom/log_translator.dart';
import 'package:logecom/translator/string_mapper.dart';

class ConsoleTransportConfig {
  const ConsoleTransportConfig({
    this.diffTime = false,
    this.alignMessages = false,
    this.initialAlignmentValue = 0,
    this.timestampFormat = 'yyyy-mm-dd HH:MM:ss.S',
    this.printingMethod = PrintingMethod.stdErr,
    this.colorize = true,
  });

  /// Print diff time between logs entries of the same category
  final bool diffTime;
  final bool colorize;
  final bool alignMessages;
  final int initialAlignmentValue;
  final String timestampFormat;
  final PrintingMethod printingMethod;
}

class ConsoleTransport implements LogTranslator {
  ConsoleTransport({this.config = const ConsoleTransportConfig()}) {
    if (config.printingMethod == PrintingMethod.stdOut) {
      _printer = (line) => stdout.writeln(line);
    } else if (config.printingMethod == PrintingMethod.stdErr) {
      _printer = (line) => stderr.writeln(line);
    } else if (config.printingMethod == PrintingMethod.developerLog) {
      _printer = (line) {
        final parts = line.split(' ');
        developer.log(parts.skip(2).join(' '), name: parts[1]);
      };
    } else if (config.printingMethod == PrintingMethod.print) {
      _printer = (line) => print(line); // ignore: avoid_print
    }

    if (config.colorize &&
        config.printingMethod != PrintingMethod.developerLog &&
        config.printingMethod != PrintingMethod.print) {
      _levelColor[LogLevel.warn] = ANSIPainter.yellow;
      _levelColor[LogLevel.info] = ANSIPainter.green;
      _levelColor[LogLevel.fatal] = ANSIPainter.red;
      _levelColor[LogLevel.error] = ANSIPainter.red;
      _levelColor[LogLevel.debug] = ANSIPainter.cyan;
      _levelColor[LogLevel.log] = ANSIPainter.white;
      _lgp = ANSIPainter.gray;
      _gp = ANSIPainter.white;
    }

    _timestampFormatter = DateFormat(config.timestampFormat);
    _categoryMaxLength = config.initialAlignmentValue;
  }

  final ConsoleTransportConfig config;
  late final DateFormat _timestampFormatter;
  LinePrinter _printer = dummyStringMapper;
  StringMapper _lgp = dummyStringMapper; // light gray painter
  StringMapper _gp = dummyStringMapper; // gray painter
  final _categoryLastTime = <String, DateTime>{};
  final Map<String, StringMapper> _levelColor = {};
  final Map<String, String> _levelLabel = {
    LogLevel.warn: 'WRN',
    LogLevel.info: 'INF',
    LogLevel.fatal: 'FTL',
    LogLevel.error: 'ERR',
    LogLevel.debug: 'DBG',
    LogLevel.log: 'LOG',
  };
  int _categoryMaxLength = 0;

  @override
  void translate(LogEntry entry, LogTranslatorNextFunction? next) {
    final now = DateTime.now();

    final logLevelPainter = _levelColor[entry.level] ?? dummyStringMapper;
    final levelLabel = _levelLabel[entry.level] ?? 'DBG';
    final logLevel = _lgp('[') + logLevelPainter(levelLabel) + _lgp(']');

    var category = entry.category;
    if (config.diffTime) {
      final lastTime = _categoryLastTime[entry.category] ?? now;
      final duration = prettyDuration(
        now.difference(lastTime),
        abbreviated: true,
        tersity: DurationTersity.millisecond,
      );
      category += ' +$duration';
      _categoryLastTime[entry.category] = now;
    }
    if (config.alignMessages) {
      _categoryMaxLength = max(_categoryMaxLength, category.length);
      category = category.padRight(_categoryMaxLength);
    }
    if (!config.colorize) {
      category += ' -';
    }
    category = _gp(category);

    var dateTime = _timestampFormatter.format(now);
    if (config.timestampFormat.contains('.S')) {
      // dim microseconds
      dateTime = dateTime.replaceAllMapped(RegExp(r'\.\d{3,3}'), (match) {
        return _lgp(match.group(0)!);
      });
    }

    // prepare context
    for (var i = 0; i < entry.context.length; i++) {
      entry.context[i] = entry.context[i].toString();
    }

    // delimiter between message and context if they are on the same line
    if (entry.context.isNotEmpty) {
      final firstElement = entry.context.first;
      if (firstElement is String && !firstElement.startsWith('\n')) {
        entry.context.insert(0, _lgp(':'));
      }
    }

    final lineItems = [
      dateTime,
      logLevel,
      category,
      entry.message,
      ...entry.context.map((e) => e.toString()),
    ];

    final lineStr = lineItems.where((s) => s != '').join(' ');
    _printer(lineStr.trim());

    if (next != null) next(entry);
  }
}

enum PrintingMethod {
  /// Simple stdout.
  /// NOTE: Doesn't work with iOS Simulator.
  stdOut,

  /// The most performant.
  /// NOTE: Doesn't work with iOS Simulator.
  stdErr,

  /// Useful with dev tools
  developerLog,

  /// Useful with Xcode debug
  print,
}

typedef LinePrinter = void Function(String line);
