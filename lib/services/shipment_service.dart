import 'package:supabase_flutter/supabase_flutter.dart';
import '../models.dart'; // Import your Shipment model

class ShipmentService {
  final String _supabaseUrl = 'https://ndillvmegwjzqwmulhvc.supabase.co';
  final String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kaWxsdm1lZ3dqenF3bXVsaHZjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0Mzk5NTk5NywiZXhwIjoyMDU5NTcxOTk3fQ.tf8OHPZmE2wLF4HsD_yS1-J_oIxG_TasqpQ49FBqLzc';
  late final SupabaseClient _supabaseClient;

  ShipmentService() {
    _supabaseClient = SupabaseClient(_supabaseUrl, _supabaseAnonKey);
  }

  Future<List<Shipment>> getShipments() async {
    final response = await _supabaseClient
        .from('shipments')
        .select('''
          *,
          from_address:addresses!from_address_id(*),
          to_address:addresses!to_address_id(*)
        ''')
      .order('created_at', ascending: false);

    try {
      if (response.error != null) {
          throw Exception('Failed to fetch shipments: ${response.error!.message}');
      }
      final data = response.data as List<dynamic>;
      List<Shipment> shipments = [];
      for (final shipmentData in data) {
        Map<String, dynamic> fixedJson = Map<String, dynamic>.from(shipmentData);
        if (fixedJson.containsKey('from_address') && fixedJson['from_address'] is List) {
          fixedJson['from_address'] = fixedJson['from_address'].isNotEmpty ? fixedJson['from_address'][0] : null;
        }

        if (fixedJson.containsKey('to_address') && fixedJson['to_address'] is List) {
          fixedJson['to_address'] = fixedJson['to_address'].isNotEmpty ? fixedJson['to_address'][0] : null;
        }
        shipments.add(Shipment.fromJson(fixedJson));
      }
      return shipments;
    } catch (e) {
      return [];
    }
  }
}