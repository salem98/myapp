import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/models.dart';

class ShipmentService {
  final SupabaseClient _supabaseClient;

  ShipmentService(this._supabaseClient);

  Future<List<Shipment>> fetchShipments() async {
    final response = await _supabaseClient.from('shipments').select('''
            *,
            from_address:addresses!from_address_id(*),
            to_address:addresses!to_address_id(*)
        ''').order('created_at', ascending: false);

        final List<Shipment> shipments = [];
        for (final item in response) {
            shipments.add(Shipment(
              id: item['id'],
              trackingNumber: item['tracking_number'],
              status: item['status'],
              createdAt: DateTime.parse(item['created_at']),
              fromAddress: Address.fromMap(item['from_address']),
              toAddress: Address.fromMap(item['to_address']),
              declaredValue: (item['declared_value'] as num).toDouble(),
              shippingCost: (item['shipping_cost'] as num).toDouble(),
            ));
        }
        return shipments;
  }
}