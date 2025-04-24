import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:myapp/models.dart';
import 'package:myapp/services/tracking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
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

  // Success animation controller
  bool _showSuccessAnimation = false;

  Future<void> _trackShipment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _shipment = null;
      _statusHistory = [];
      _showSuccessAnimation = false;
    });

    try {
      final trackingNumber = _trackingController.text.trim();
      final shipment = await _trackingService.getShipmentByTrackingNumber(trackingNumber);

      if (shipment == null) {
        setState(() {
          _errorMessage = 'Shipment not found. Please check the tracking number and try again.';
          _isLoading = false;
        });
        return;
      }

      final statusHistory = await _trackingService.getShipmentStatusHistory(shipment.id);

      // Show success animation before revealing shipment details
      setState(() {
        _isLoading = false;
        _showSuccessAnimation = true;
      });

      // Delay to show the success animation
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _shipment = shipment;
        _statusHistory = statusHistory;
        _showSuccessAnimation = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while tracking the shipment. Please try again.';
        _isLoading = false;
      });
    }
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat.yMMMd().format(date);
    } catch (_) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Glassmorphic AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white.withOpacity(0.7)
            : Colors.black.withOpacity(0.7),
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  'https://placehold.co/40x40?text=ZTO',
                  width: 32,
                  height: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Shipment Tracking',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                ? Colors.white.withOpacity(0.3)
                : Colors.grey.shade800.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {},
              tooltip: 'Scan QR Code',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Glassmorphic Tracking Hero Section
            Container(
              margin: const EdgeInsets.only(top: 60), // Add margin for AppBar
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade700.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Package Tracking',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Enter your tracking number to get real-time updates',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Neumorphic Input Field
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              // Outer shadow (darker on bottom-right)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(5, 5),
                              ),
                              // Inner shadow (lighter on top-left)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),
                                blurRadius: 10,
                                offset: const Offset(-5, -5),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _trackingController,
                            decoration: InputDecoration(
                              hintText: 'e.g., TNS123456',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Theme.of(context).brightness == Brightness.light
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey.shade800.withOpacity(0.9),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              prefixIcon: const Icon(Icons.search),
                              suffixIcon: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                                  onPressed: () {},
                                  tooltip: 'Scan QR Code',
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a tracking number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Neumorphic Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade50,
                            boxShadow: [
                              // Outer shadow (darker on bottom-right)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(5, 5),
                              ),
                              // Inner shadow (lighter on top-left)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),
                                blurRadius: 10,
                                offset: const Offset(-5, -5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _trackShipment,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.blue.shade700,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.blue.shade700,
                                  ),
                                )
                              : const Text(
                                  'TRACK PACKAGE',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                            ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Popular Tracking Info
            const SizedBox(height: 24),
            const Text(
              'Popular Tracking Services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildServiceCard(Icons.local_shipping, 'Express'),
                const SizedBox(width: 12),
                _buildServiceCard(Icons.flight_takeoff, 'Air Freight'),
                const SizedBox(width: 12),
                _buildServiceCard(Icons.directions_boat, 'Sea Freight'),
              ],
            ),
            const SizedBox(height: 24),
            // Success Animation
            if (_showSuccessAnimation) ...[
              const SizedBox(height: 24),
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.check_circle,
                            size: 80,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Shipment Found!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Loading shipment details...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],

            if (_errorMessage != null && _shipment == null && !_showSuccessAnimation) ...[
              const SizedBox(height: 16),
              // Custom Error State with Illustration
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Error Illustration
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.8, end: 1.0),
                      duration: const Duration(milliseconds: 1500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: MediaQuery.of(context).size.width < 400 ? 80 : 120,
                            height: MediaQuery.of(context).size.width < 400 ? 80 : 120,
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 60,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Shipment Not Found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        _trackingController.clear();
                        setState(() {
                          _errorMessage = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_shipment != null) ...[
              const SizedBox(height: 24),
              // Animated Shipment Card
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  // Neumorphic Shipment Card
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                      ? Colors.grey.shade50
                      : Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      // Outer shadow (darker on bottom-right)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(8, 8),
                      ),
                      // Inner shadow (lighter on top-left)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.9),
                        blurRadius: 15,
                        offset: const Offset(-8, -8),
                      ),
                    ],
                  ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with tracking number and status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade50,
                            Colors.grey.shade50,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tracking #${_shipment!.trackingNumber}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Created on ${formatDate(_shipment!.createdAt)}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusChip(_shipment!.status),
                        ],
                      ),
                    ),

                    // Shipment details
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Carrier and service info
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.local_shipping,
                                  color: Colors.blue.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Carrier & Service',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '${_shipment!.carrier ?? 'ZTO Express'} - ${_shipment!.service ?? 'Standard'}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Delivery time
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Colors.green.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Estimated Delivery',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      formatDate(_shipment!.estimatedDelivery),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Package details
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.inventory_2,
                                  color: Colors.orange.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Package Details',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '${_shipment!.weight ?? 'N/A'} kgs, ${_shipment!.packageType ?? 'Standard'}, Total: ${_shipment!.quantity ?? 1} boxes',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const Divider(height: 32),

                          // Addresses section
                          const Text(
                            'Shipping Route',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // From address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.circle,
                                      color: Colors.blue,
                                      size: 12,
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'From',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _shipment!.origin?.toString() ??
                                          _formatAddress(_shipment!.fromAddress),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // To address
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'To',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      _shipment!.destination?.toString() ??
                                          _formatAddress(_shipment!.toAddress),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (_shipment!.deliveryInstructions != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.amber.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.amber.shade800,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Delivery Instructions',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _shipment!.deliveryInstructions!,
                                          style: TextStyle(
                                            color: Colors.amber.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                ),
              ),
              if (_statusHistory.isNotEmpty) ...[
                const SizedBox(height: 24),
                // Animated Timeline Card
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 24),
                    // Neumorphic Timeline Card
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        // Outer shadow (darker on bottom-right)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(8, 8),
                        ),
                        // Inner shadow (lighter on top-left)
                        BoxShadow(
                          color: Colors.white.withOpacity(0.9),
                          blurRadius: 15,
                          offset: const Offset(-8, -8),
                        ),
                      ],
                    ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Tracking History',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Timeline content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _buildStatusTimeline(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        color = Colors.green;
        break;
      case 'IN_TRANSIT':
        color = Colors.blue;
        break;
      case 'PENDING':
      case 'CREATED':
        color = Colors.orange;
        break;
      case 'EXCEPTION':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildServiceCard(IconData icon, String label) {
    return Expanded(
      child: Container(
        // Neumorphic Service Card
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            // Outer shadow (darker on bottom-right)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
            // Inner shadow (lighter on top-left)
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 8,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blue.shade700,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(Address? address) {
    if (address == null) return 'N/A';
    return '${address.name}, ${address.city}, ${address.state}, ${address.postalCode}';
  }

  List<Widget> _buildStatusTimeline() {
    if (_statusHistory.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Empty State Illustration
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.history_toggle_off,
                      size: 50,
                      color: Colors.blue.shade300,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No tracking updates yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Check back later for shipment status updates',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    return _statusHistory.asMap().entries.map((entry) {
      final index = entry.key;
      final status = entry.value;
      final isLast = index == _statusHistory.length - 1;

      // Determine status color based on status text
      Color statusColor;
      switch ((status['status'] ?? '').toString().toUpperCase()) {
        case 'DELIVERED':
          statusColor = Colors.green;
          break;
        case 'IN_TRANSIT':
          statusColor = Colors.blue;
          break;
        case 'PENDING':
        case 'CREATED':
          statusColor = Colors.orange;
          break;
        case 'EXCEPTION':
          statusColor = Colors.red;
          break;
        default:
          statusColor = Colors.blue;
      }

      return AnimatedContainer(
        duration: Duration(milliseconds: 500 + (index * 100)),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Animated status dot
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500 + (index * 150)),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: statusColor, width: 3),
                        ),
                        child: Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Animated timeline line
                if (!isLast)
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 60),
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOut,
                    builder: (context, double value, child) {
                      return Container(
                        width: 2,
                        height: value,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              statusColor,
                              statusColor.withOpacity(0.5),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Animated content
            Expanded(
              child: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(milliseconds: 500 + (index * 100)),
                curve: Curves.easeOut,
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(20 * (1 - value), 0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(
                      color: statusColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            status['status'] ?? 'Status Update',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatTimelineDate(status['created_at']),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status['location'] ?? 'Unknown Location',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (status['notes'] != null && status['notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          status['notes'] ?? '',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  String _formatTimelineDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }
}
