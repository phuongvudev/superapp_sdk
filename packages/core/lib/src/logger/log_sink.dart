import 'dart:convert';
import 'dart:io';
import 'package:core/src/logger/log_level.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

abstract class LogSink {
  final String name;

  const LogSink(this.name);

  Future<void> log(LogLevel level, String message,
      {dynamic error, StackTrace stackTrace = StackTrace.empty});
}

class FileLogSink extends LogSink {
  late final File _logFile;

  FileLogSink(super.name) {
    _init(name);
  }

  Future<void> _init(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$fileName.log');
      if (!_logFile.existsSync()) {
        await _logFile.create();
      }
    } catch (e) {
      print("Cannot init the log file: $e");
    }
  }

  @override
  Future<void> log(LogLevel level, String message,
      {dynamic error, StackTrace stackTrace = StackTrace.empty}) async {
    try {
      final now = DateTime.now().toLocal().toString();
      final formattedMessage = """
[$now] [$level] [$name]
$message
""";
      await _logFile.writeAsString("$formattedMessage\n",
          mode: FileMode.append);
      if (error != null) {
        await _logFile.writeAsString("Error: $error\n", mode: FileMode.append);
      }
      if (stackTrace != StackTrace.empty) {
        await _logFile.writeAsString("StackTrace: $stackTrace\n",
            mode: FileMode.append);
      }
    } catch (e) {
      print("Cannot write in the log file: $e");
    }
  }
}

class ServerLogSink extends LogSink {
  final String serverUrl;

  ServerLogSink(this.serverUrl, super.name);

  @override
  Future<void> log(LogLevel level, String message,
      {dynamic error, StackTrace stackTrace = StackTrace.empty}) async {
    try {
      final now = DateTime.now().toLocal().toString();
      final formattedMessage = "[$now] [$level] [$name] $message";
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'log': formattedMessage,
          'error': error.toString(),
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
            'Failed to send log to server. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Failed to send log to server: $e');
    }
  }
}

class ConsoleLogSink extends LogSink {

  ConsoleLogSink(super.name);

  @override
  Future<void> log(LogLevel level, String message,
      {dynamic error, StackTrace stackTrace = StackTrace.empty}) async {
    final now = DateTime.now().toLocal().toString();
    final levelColor = _getColorForLevel(level);

    final formattedMessage = """
$levelColor
[$now] [$level] [$name]
$message
\u001b[0m"""; // Reset color
    print(formattedMessage);
    if (error != null) {
      print("Error: $error");
    }
    if (stackTrace != StackTrace.empty) {
      print("StackTrace: $stackTrace");
    }
  }

  String _getColorForLevel(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return "\u001b[32m"; // Green
      case LogLevel.warning:
        return "\u001b[33m"; // Yellow
      case LogLevel.error:
        return "\u001b[31m"; // Red
      case LogLevel.debug:
        return "\u001b[36m"; // Cyan
      case LogLevel.verbose:
        return "\u001b[37m"; // White
      case LogLevel.fatal:
      case LogLevel.wtf:
        return "\u001b[35m"; // Magenta
    }
  }
}
