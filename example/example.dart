import 'package:logecom/logecom.dart';

void main() {
  Logecom.instance.pipeline = [
    HttpFormatter(),
    ConsoleTransport(),
  ];

  final logger = Logecom.createLogger('main');

  logger.warn('ATTENTION');
  logger.info('Starting main example');
  logger.debug('Logger pipeline length = ${Logecom.instance.pipeline.length} ');
}
