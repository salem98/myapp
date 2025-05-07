import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/models.dart';

class TrackingHistoryService {
  static const String _trackingHistoryKey = 'tracking_history';
  static const int _maxHistoryItems = 10; // Limit history to 10 items

  // Save a shipment to tracking history
  Future<void> saveToHistory(Shipment shipment) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing history
      List<Map<String, dynamic>> history = await getTrackingHistory();
      
      // Check if this tracking number already exists in history
      final existingIndex = history.indexWhere(
        (item) => item['trackingNumber'] == shipment.trackingNumber
      );
      
      // If it exists, remove it (we'll add it to the top)
      if (existingIndex != -1) {
        history.removeAt(existingIndex);
      }
      
      // Create a simplified version of the shipment to store
      final shipmentData = {
        'id': shipment.id,
        'trackingNumber': shipment.trackingNumber,
        'carrier': shipment.carrier ?? 'Unknown',
        'status': shipment.status,
        'createdAt': shipment.createdAt.toIso8601String(),
        'destination': shipment.destination ?? 'Unknown',
        'receiverName': shipment.receiverName ?? 'Unknown',
      };
      
      // Add to the beginning of the list
      history.insert(0, shipmentData);
      
      // Limit the history size
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }
      
      // Save back to shared preferences
      await prefs.setString(_trackingHistoryKey, jsonEncode(history));
    } catch (e) {
      print('Error saving tracking history: $e');
    }
  }

  // Get the tracking history
  Future<List<Map<String, dynamic>>> getTrackingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_trackingHistoryKey);
      
      if (historyJson == null || historyJson.isEmpty) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(historyJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting tracking history: $e');
      return [];
    }
  }

  // Clear the tracking history
  Future<void> clearTrackingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_trackingHistoryKey);
    } catch (e) {
      print('Error clearing tracking history: $e');
    }
  }
}