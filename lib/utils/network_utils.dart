import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  /// Checks if the device has an active internet connection
  static Future<bool> hasInternetConnection() async {
    if (kIsWeb) {
      // For web, we assume there's internet connection
      // Web platform doesn't have access to NetworkInformation API in all browsers
      return true;
    }

    // List of reliable hosts to try
    final hosts = ['google.com', 'cloudflare.com', 'apple.com'];

    for (final host in hosts) {
      try {
        debugPrint('Checking internet connection using host: $host');
        final result = await InternetAddress.lookup(host);
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          debugPrint('Internet connection available');
          return true;
        }
      } on SocketException catch (e) {
        debugPrint('Socket exception when checking $host: $e');
        // Continue to the next host
      } catch (e) {
        debugPrint('Error checking internet connection with $host: $e');
        // Continue to the next host
      }
    }

    debugPrint('No internet connection available after trying all hosts');
    return false;
  }
}
