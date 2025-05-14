import 'package:skit_sdk/kit.dart';

class FirebaseCrashlyticsSink extends LogSink {
  FirebaseCrashlyticsSink(super.name);
  
  @override
  Future<void> log(LogLevel level, String message, {error, StackTrace stackTrace = StackTrace.empty}) {
    // TODO: implement log
    throw UnimplementedError();
  }

}