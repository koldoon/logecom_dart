/// Collection of simple string decorators for colorful console messages
abstract class ANSIPainter {
  static String black(String s) => '\x1B[30m$s\x1B[0m';
  static String red(String s) => '\x1B[31m$s\x1B[0m';
  static String green(String s) => '\x1B[32m$s\x1B[0m';
  static String yellow(String s) => '\x1B[33m$s\x1B[0m';
  static String blue(String s) => '\x1B[34m$s\x1B[0m';
  static String magenta(String s) => '\x1B[35m$s\x1B[0m';
  static String cyan(String s) => '\x1B[36m$s\x1B[0m';
  static String white(String s) => '\x1B[37m$s\x1B[0m'; // "gray"
  static String gray(String s) => '\x1B[90m$s\x1B[0m'; // "lighter gray"
}
