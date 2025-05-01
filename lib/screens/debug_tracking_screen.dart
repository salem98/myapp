import 'package:flutter/material.dart';
import 'package:myapp/models.dart';
import 'package:myapp/services/tracking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DebugTrackingScreen extends StatefulWidget {
  const DebugTrackingScreen({super.key});

  @override
  State<DebugTrackingScreen> createState() => _DebugTrackingScreenState();
}

class _DebugTrackingScreenState extends State<DebugTrackingScreen> {
  final TextEditingController _trackingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Shipment? _shipment;
  List<Map<String, dynamic>> _statusHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  late final TrackingService _trackingService;

  @override
  void initState() {
    super.initState();
    final supabaseClient = Supabase.instance.client;
    _trackingService = TrackingService(supabaseClient);
  }

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _trackShipment() async {
    print("Track button pressed - starting tracking process");
    
    // Check if form is valid
    if (_formKey.currentState == null) {
      print("Error: Form key current state is null");
      setState(() {
        _errorMessage = 'Form validation error. Please try again.';
      });
      return;
    }
    
    if (!_formKey.currentState!.validate()) {
      print("Form validation failed");
      return;
    }

    print("Form validation passed, proceeding with tracking");
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _shipment = null;
      _statusHistory = [];
    });

    try {
      final trackingNumber = _trackingController.text.trim();
      print("Searching for tracking number: $trackingNumber");
      
      final shipment = await _trackingService.getShipmentByTrackingNumber(trackingNumber);
      print("Tracking service response: ${shipment != null ? 'Shipment found' : 'Shipment not found'}");

      if (shipment == null) {
        setState(() {
          _errorMessage = 'Shipment not found. Please check the tracking number and try again.';
          _isLoading = false;
        });
        return;
      }

      final statusHistory = await _trackingService.getShipmentStatusHistory(shipment.id);
      print("Status history fetched: ${statusHistory.length} entries");

      setState(() {
        _shipment = shipment;
        _statusHistory = statusHistory;
        _isLoading = false;
      });
      print("Tracking completed successfully");
    } catch (e) {
      print("Error during tracking: $e");
      setState(() {
        _errorMessage = 'An error occurred while tracking the shipment. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Tracking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _trackingController,
                    decoration: const InputDecoration(
                      labelText: 'Tracking Number',
                      hintText: 'Enter tracking number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a tracking number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _trackShipment,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('TRACK PACKAGE'),
                  ),
                ],
              ),
            ),
            
            if (_errorMessage != null && _shipment == null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              
            if (_shipment != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text('Tracking #: ${_shipment!.trackingNumber}', 
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Status: ${_shipment!.status}', 
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('Carrier: ${_shipment!.carrier ?? 'N/A'}'),
                      Text('Service: ${_shipment!.service ?? 'N/A'}'),
                      Text('Receiver: ${_shipment!.receiverName ?? _shipment!.toAddress?.name ?? 'N/A'}'),
                      
                      const SizedBox(height: 16),
                      const Text('Status History:', style: TextStyle(fontWeight: FontWeight.bold)),
                      
                      if (_statusHistory.isEmpty)
                        const Text('No status history available')
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _statusHistory.map((status) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('${status['created_at'] ?? ''}: ${status['status'] ?? 'Unknown'}'),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}