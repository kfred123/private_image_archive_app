import 'dart:developer' as developer;
class Logging {
  static void logError(String message) {
    developer.log(message, time: DateTime.now());
  }

  static void logException(String message, Exception e) {
    developer.log(message, time: DateTime.now());
  }

  static void logInfo(String message) {
    developer.log(message, time: DateTime.now());
  }
}