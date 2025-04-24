import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:myapp/services/shipment_service.dart';
import 'models.dart';
import 'services/shipment_service.dart';

// test note 123
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ndillvmegwjzqwmulhvc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5kaWxsdm1lZ3dqenF3bXVsaHZjIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc0Mzk5NTk5NywiZXhwIjoyMDU5NTcxOTk3fQ.tf8OHPZmE2wLF4HsD_yS1-J_oIxG_TasqpQ49FBqLzc',
  );
    final supabaseClient = Supabase.instance.client;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shipment Tracking Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ShipmentListScreen(),
    );
  }
}

class ShipmentListScreen extends StatefulWidget {
  const ShipmentListScreen({super.key});

  @override
  State<ShipmentListScreen> createState() => _ShipmentListScreenState();
}

class _ShipmentListScreenState extends State<ShipmentListScreen> {
  late Future<List<Shipment>> _shipmentsFuture;
    final supabaseClient = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
        final shipmentService = ShipmentService(supabaseClient);
    _shipmentsFuture = shipmentService.fetchShipments();
  }
  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat.yMMMd().format(date);
    } catch (_) {
      return 'Invalid Date';
    }
  }

  String formatCurrency(double? amount) {
    if (amount == null) return '\$0.00';
    return NumberFormat.currency(symbol: '\$').format(amount);
      }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipments'),
      ),
      body: FutureBuilder<List<Shipment>>(
        future: _shipmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final shipments = snapshot.data!;
            return ListView.builder(
              itemCount: shipments.length,
              itemBuilder: (context, index) {
                final shipment = shipments[index];
                return ListTile(
                  title: Text('Tracking: ${shipment.trackingNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                          'Origin: ${shipment.fromAddress?.city ?? 'N/A'}, ${shipment.fromAddress?.state ?? 'N/A'}',),
                      Text(
                          'Destination: ${shipment.toAddress?.city ?? 'N/A'}, ${shipment.toAddress?.state ?? 'N/A'}'),
                      Text('Created: ${formatDate(shipment.createdAt)}',),
                      Text(
                          'Declared Value: ${formatCurrency(shipment.declaredValue)}',),
                      Text(
                          'Shipping Cost: ${formatCurrency(shipment.shippingCost)}'),
                      Text('Status: ${shipment.status}'),
                    ],
                  ),
                  isThreeLine: true,

                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
