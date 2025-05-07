import 'package:flutter/material.dart';

class TrackingServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;

  const TrackingServiceCard({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
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
}

class TrackingServicesRow extends StatelessWidget {
  const TrackingServicesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            TrackingServiceCard(icon: Icons.local_shipping, label: 'Express'),
            const SizedBox(width: 12),
            TrackingServiceCard(icon: Icons.flight_takeoff, label: 'Air Freight'),
            const SizedBox(width: 12),
            TrackingServiceCard(icon: Icons.directions_boat, label: 'Sea Freight'),
          ],
        ),
      ],
    );
  }
}