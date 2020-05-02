import 'dart:developer' as developer;
class Logging {
  static void logError(String message) {
    developer.log(message, time: DateTime.now());
  }
}