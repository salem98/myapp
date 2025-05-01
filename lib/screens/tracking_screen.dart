import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models.dart';
import 'package:myapp/services/tracking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingScreen extends StatefulWidget {
  final String? trackingNumber;

  const TrackingScreen({super.key, this.trackingNumber});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _trackingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Shipment? _shipment;
  List<Map<String, dynamic>> _statusHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Animation controller for the tracking form
  late AnimationController _animationController;
  late Animation<double> _formOpacityAnimation;
  
  late final TrackingService _trackingService;

  @override
  void initState() {
    super.initState();
    final supabaseClient = Supabase.instance.client;
    _trackingService = TrackingService(supabaseClient);
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _formOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // If a tracking number was provided, set it in the controller and track it
    if (widget.trackingNumber != null && widget.trackingNumber!.isNotEmpty) {
      _trackingController.text = widget.trackingNumber!;
      
      print("TrackingScreen: Received tracking number: ${widget.trackingNumber}");

      // IMPORTANT: Track immediately without delay
      print("TrackingScreen: Calling _trackShipment() immediately");
      _trackShipment();
    }
  }

  @override
  void dispose() {
    _trackingController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _trackShipment() async {
    // Skip validation if the form is not yet built (when called from initState)
    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

      setState(() {
        _shipment = shipment;
        _statusHistory = statusHistory;
        _isLoading = false;
      });
      
      // Animate the form out when shipment is found
      _animationController.forward();
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while tracking the shipment. Please try again.';
        _isLoading = false;
      });
    }
  }
  
  // Reset the tracking form and show it again
  void _resetTracking() {
    setState(() {
      _shipment = null;
      _statusHistory = [];
      _errorMessage = null;
      _trackingController.clear();
    });
    
    // Animate the form back in
    _animationController.reverse();
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.local_shipping_rounded,
                size: 24,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Shipment Tracking'),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () {},
            tooltip: 'Scan QR Code',
            style: IconButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Add a floating action button that appears when shipment details are shown
      floatingActionButton: _shipment != null 
        ? FloatingActionButton.extended(
            onPressed: _resetTracking,
            icon: const Icon(Icons.search),
            label: const Text('Track Another'),
            tooltip: 'Track another shipment',
          )
        : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tracking Form Section - Animated to hide/show
            FadeTransition(
              opacity: _formOpacityAnimation,
              child: AnimatedSizeAndFade(
                show: _shipment == null,
                child: _buildTrackingForm(theme),
              ),
            ),
            
            // Shipment Details Section - Shows when a shipment is found
            if (_shipment != null)
              _buildShipmentDetails(theme),
              
            const SizedBox(height: 16),
            
            // Error Message Section
            if (_errorMessage != null) 
              Card(
                elevation: 0,
                color: theme.colorScheme.errorContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
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
  
  // Widget for the tracking form
  Widget _buildTrackingForm(ThemeData theme) {
    return Card(
      key: const ValueKey('tracking_input'),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping_rounded,
                  color: theme.colorScheme.onPrimary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Package Tracking',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your tracking number to get real-time updates',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimary.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _trackingController,
                      decoration: InputDecoration(
                        hintText: 'e.g., TNS123456',
                        hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 20,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
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
                  FilledButton(
                    onPressed: _isLoading ? null : _trackShipment,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.onPrimary,
                      foregroundColor: theme.colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Text(
                            'TRACK PACKAGE',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Widget for the shipment details
  Widget _buildShipmentDetails(ThemeData theme) {
    return Column(
      key: const ValueKey('shipment_details'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tracking #${_shipment!.trackingNumber}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Add a small button to track another shipment
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _resetTracking,
                      tooltip: 'Track another shipment',
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Status chip with color based on status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(theme, _shipment!.status),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _shipment!.status,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Shipment Details',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_shipping_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Carrier: ${_shipment!.carrier ?? 'N/A'}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Receiver: ${_shipment!.receiverName ?? _shipment!.toAddress?.name ?? 'N/A'}'),
                  ],
                ),                
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_post_office_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Service: ${_shipment!.service ?? 'N/A'}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Est. Delivery: ${formatDate(_shipment!.estimatedDelivery)}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.inventory_2_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Package: ${_shipment!.weight ?? 'N/A'} kgs, ${_shipment!.quantity ?? 0} boxes'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.flight_takeoff_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Origin: ${_shipment!.origin ?? 'N/A'}'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.flight_land_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Destination: ${_shipment!.destination ?? 'N/A'}'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Status History',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (_statusHistory.isEmpty)
                  Text(
                    'No status updates available',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  ..._statusHistory.map((status) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        '${status['date']}: ${status['status']}',
                        style: theme.textTheme.bodySmall,
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  // Helper method to get color based on shipment status
  Color _getStatusColor(ThemeData theme, String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('delivered')) {
      return Colors.green;
    } else if (statusLower.contains('transit')) {
      return theme.colorScheme.primary;
    } else if (statusLower.contains('pending') || statusLower.contains('processing')) {
      return Colors.orange;
    } else if (statusLower.contains('exception') || statusLower.contains('failed')) {
      return theme.colorScheme.error;
    }
    return theme.colorScheme.secondary;
  }
}

// Custom widget for animated size and fade transitions
class AnimatedSizeAndFade extends StatelessWidget {
  final Widget child;
  final bool show;
  final Duration duration;

  const AnimatedSizeAndFade({
    super.key,
    required this.child,
    required this.show,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1.0,
            child: child,
          ),
        );
      },
      child: show ? child : const SizedBox.shrink(),
    );
  }
}
