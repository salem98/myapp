import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Subscribe to notifications for all users (guest/admin) without user filtering
  void subscribeToAllNotifications(void Function(Map<String, dynamic>) onNotification) {
    supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      print('Supabase Realtime push received: $data');
      for (final notification in data) {
        print('Notification item: $notification');
        onNotification(notification);
      }
    }, onError: (error) {
      print('Supabase Realtime subscription error: $error');
    });
  }

  /// Insert a notification record into the 'notifications' table
  /// Returns true if successful, false otherwise
  Future<bool> insertNotification(String title, String message) async {
    try {
      final response = await supabase.from('notifications').insert({
        'title': title,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      // In newer Supabase versions, errors are thrown as exceptions
      return true;
    } catch (e) {
      print('Exception inserting notification: $e');
      return false;
    }
  }

  /// Fetch all notifications ordered by creation time
  Future<List<Map<String, dynamic>>> getAllNotifications() async {
    try {
      final data = await supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: true);
      
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
}