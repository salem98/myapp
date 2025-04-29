import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/models.dart';

class TrackingService {
  final SupabaseClient _supabaseClient;

  TrackingService(this._supabaseClient);

  Future<Shipment?> getShipmentByTrackingNumber(String trackingNumber) async {
    try {
      // First try to find by tracking_number
      final response = await _supabaseClient
          .from('shipments')
          .select('''
            *,
            from_address:addresses!from_address_id(*),
            to_address:addresses!to_address_id(*)
          ''')
          .or('tracking_number.ilike.$trackingNumber,courier_tracking_number.ilike.$trackingNumber')
          .limit(1);

      if (response.isEmpty) {
        return null;
      }

      final item = response[0];

      return Shipment(
        id: item['id'],
        trackingNumber: item['tracking_number'],
        courierTrackingNumber: item['courier_tracking_number'],
        carrier: item['carrier'],
        service: item['service'],
        status: item['status'],
        fromAddressId: item['from_address_id'],
        toAddressId: item['to_address_id'],
        weight: item['weight']?.toDouble(),
        dimensions: item['dimensions'] != null ? Dimensions.fromJson(item['dimensions']) : null,
        packageType: item['package_type'],
        packageContents: item['package_contents'],
        declaredValue: item['declared_value']?.toDouble(),
        shippingCost: item['shipping_cost']?.toDouble(),
        labelUrl: item['label_url'],
        createdAt: DateTime.parse(item['created_at']),
        estimatedDelivery: item['estimated_delivery'] != null ? DateTime.parse(item['estimated_delivery']) : null,
        actualDelivery: item['actual_delivery'] != null ? DateTime.parse(item['actual_delivery']) : null,
        deliveryInstructions: item['delivery_instructions'],
        signatureRequired: item['signature_required'],
        deliveryAttempts: item['delivery_attempts'],
        priority: item['priority'],
        tags: item['tags'] != null ? List<String>.from(item['tags']) : null,
        notes: item['notes'],
        fromAddress: item['from_address'] != null ? Address.fromMap(item['from_address']) : null,
        toAddress: item['to_address'] != null ? Address.fromMap(item['to_address']) : null,
        origin: item['origin'],
        destination: item['destination'],
        quantity: item['quantity'],
        receiverName: item['receiver_name'],
      );
    } catch (e, stackTrace) {
      // Use a logger instead of print in production
      // Logger.error('Error fetching shipment by tracking number: $e');
      debugPrint('Error fetching shipment by tracking number: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Tracking number used: $trackingNumber');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getShipmentStatusHistory(String shipmentId) async {
    try {
      final response = await _supabaseClient
          .from('shipment_status_history')
          .select('*')
          .eq('shipment_id', shipmentId)
          .order('created_at', ascending: false);

      return response;
    } catch (e, stackTrace) {
      // Use a logger instead of print in production
      // Logger.error('Error fetching shipment status history: $e');
      debugPrint('Error fetching shipment status history: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Shipment ID used: $shipmentId');
      return [];
    }
  }
}
