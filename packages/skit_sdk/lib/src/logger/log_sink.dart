part of 'logger.dart';

/// Abstract base class for log sinks.
/// A log sink is responsible for handling log messages (e.g., writing to a file, sending to a server).
abstract class LogSink {
  /// The name of the log sink.
  final String name;

  /// Constructor for initializing the log sink with a name.
  const LogSink(this.name);

  /// Logs a message with the specified log level.
  ///
  /// [level] - The severity level of the log.
  /// [message] - The log message.
  /// [error] - Optional error details.
  /// [stackTrace] - Optional stack trace details.
  Future<void> log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace stackTrace = StackTrace.empty,
  });
}

/// A log sink that writes log messages to a file.
class FileLogSink extends LogSink {
  late final File _logFile;

  /// Constructor for initializing the file log sink with a name.
  FileLogSink(super.name) {
    _init(name);
  }

  /// Initializes the log file in the application's documents directory.
  Future<void> _init(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$fileName.log');
      if (!_logFile.existsSync()) {
        await _logFile.create();
      }
    } catch (e) {
      print("Cannot initialize the log file: $e");
    }
  }

  /// Logs a message to the file.
  @override
  Future<void> log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace stackTrace = StackTrace.empty,
  }) async {
    try {
      final now = DateTime.now().toLocal().toString();
      final formattedMessage = """
[$now] [$level] [$name]
$message
""";
      await _logFile.writeAsString(
        "$formattedMessage\n",
        mode: FileMode.append,
      );
      if (error != null) {
        await _logFile.writeAsString("Error: $error\n", mode: FileMode.append);
      }
      if (stackTrace != StackTrace.empty) {
        await _logFile.writeAsString(
          "StackTrace: $stackTrace\n",
          mode: FileMode.append,
        );
      }
    } catch (e) {
      print("Cannot write to the log file: $e");
    }
  }
}

/// A log sink that sends log messages to a remote server.
class ServerLogSink extends LogSink {
  /// The URL of the remote server.
  final String serverUrl;

  /// Constructor for initializing the server log sink with a server URL and name.
  ServerLogSink(this.serverUrl, super.name);

  /// Logs a message to the remote server.
  @override
  Future<void> log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace stackTrace = StackTrace.empty,
  }) async {
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
          'error': error?.toString() ?? '',
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(
          'Failed to send log to server. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Failed to send log to server: $e');
    }
  }
}

/// A log sink that writes log messages to the console.
class ConsoleLogSink extends LogSink {
  /// Constructor for initializing the console log sink with a name.
  ConsoleLogSink(super.name);

  /// Logs a message to the console with color-coded log levels.
  @override
  Future<void> log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace stackTrace = StackTrace.empty,
  }) async {
    if (kDebugMode) {
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
  }

  /// Returns the color code for the specified log level.
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
