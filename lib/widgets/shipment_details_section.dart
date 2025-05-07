import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models.dart';

class ShipmentDetailsSection extends StatelessWidget {
  final Shipment shipment;

  const ShipmentDetailsSection({
    super.key,
    required this.shipment,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main shipment details card
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(8, 8),
              ),
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
                            'Tracking #${shipment.trackingNumber}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Created on ${formatDate(shipment.createdAt)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(shipment.status),
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
                    _buildInfoRow(
                      icon: Icons.local_shipping,
                      iconColor: Colors.blue.shade700,
                      iconBgColor: Colors.blue.shade50,
                      title: 'Carrier & Service',
                      value: '${shipment.carrier ?? 'ZTO Express'} - ${shipment.service ?? 'Standard'}',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Delivery time
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      iconColor: Colors.green.shade700,
                      iconBgColor: Colors.green.shade50,
                      title: 'Estimated Delivery',
                      value: formatDate(shipment.estimatedDelivery),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Package details
                    _buildInfoRow(
                      icon: Icons.inventory_2,
                      iconColor: Colors.orange.shade700,
                      iconBgColor: Colors.orange.shade50,
                      title: 'Package Details',
                      value: '${shipment.weight ?? 'N/A'} kgs, ${shipment.packageType ?? 'Standard'}, Total: ${shipment.quantity ?? 1} boxes',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Receiver information
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(8, 8),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.9),
                blurRadius: 15,
                offset: const Offset(-8, -8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: _buildInfoRow(
            icon: Icons.person,
            iconColor: Colors.purple.shade700,
            iconBgColor: Colors.purple.shade50,
            title: 'Receiver',
            value: shipment.toAddress?.name ?? 'N/A',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
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

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    try {
      return DateFormat.yMMMd().format(date);
    } catch (_) {
      return 'Invalid Date';
    }
  }
}