abstract class LogecomTextPainter {
  String black(String s);
  String red(String s);
  String green(String s);
  String yellow(String s);
  String blue(String s);
  String magenta(String s);
  String cyan(String s);
  String white(String s);
  String gray(String s);
}

class NoColorsTextPainter implements LogecomTextPainter {
  const NoColorsTextPainter();

  @override
  String black(String s) => s;

  @override
  String red(String s) => s;

  @override
  String green(String s) => s;

  @override
  String yellow(String s) => s;

  @override
  String blue(String s) => s;

  @override
  String magenta(String s) => s;

  @override
  String cyan(String s) => s;

  @override
  String white(String s) => s;

  @override
  String gray(String s) => s;
}

/// Used together with stdOut or stdErr printing methods
class StdOutPainter implements LogecomTextPainter {
  @override
  String black(String s) => '\x1B[30m$s\x1B[0m';

  @override
  String red(String s) => '\x1B[31m$s\x1B[0m';

  @override
  String green(String s) => '\x1B[32m$s\x1B[0m';

  @override
  String yellow(String s) => '\x1B[33m$s\x1B[0m';

  @override
  String blue(String s) => '\x1B[34m$s\x1B[0m';

  @override
  String magenta(String s) => '\x1B[35m$s\x1B[0m';

  @override
  String cyan(String s) => '\x1B[36m$s\x1B[0m';

  @override
  String white(String s) => '\x1B[37m$s\x1B[0m'; // "gray"

  @override
  String gray(String s) => '\x1B[90m$s\x1B[0m'; // "lighter gray"
}

/// Used together with "print" printing method
class UtfPainter implements LogecomTextPainter {
  const UtfPainter();

  @override
  String black(String s) => '\u001B[30m$s\u001B[0m';

  @override
  String red(String s) => '\u001B[31m$s\u001B[0m';

  @override
  String green(String s) => '\u001B[32m$s\u001B[0m';

  @override
  String yellow(String s) => '\u001B[33m$s\u001B[0m';

  @override
  String blue(String s) => '\u001B[34m$s\u001B[0m';

  @override
  String magenta(String s) => '\u001B[35m$s\u001B[0m';

  @override
  String cyan(String s) => '\u001B[36m$s\u001B[0m';

  @override
  String white(String s) => '\u001B[37m$s\u001B[0m'; // "gray"

  @override
  String gray(String s) => '\u001B[90m$s\u001B[0m'; // "lighter gray"
}
