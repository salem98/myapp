import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Subscribe to notifications for all users (guest/admin) without user filtering
  void subscribeToAllNotifications(void Function(Map<String, dynamic>) onNotification) {
    supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
      print('Supabase Realtime push received: \$data');
      for (final notification in data) {
        print('Notification item: \$notification');
        onNotification(notification);
      }
    }, onError: (error) {
      print('Supabase Realtime subscription error: \$error');
    });
  }
}