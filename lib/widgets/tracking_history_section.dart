import 'package:flutter/material.dart';
import 'package:myapp/widgets/tracking_history_item.dart';

class TrackingHistorySection extends StatelessWidget {
  final List<Map<String, dynamic>> trackingHistory;
  final bool isLoading;
  final Function(String) onTrackAgain;
  final VoidCallback onClearHistory;

  const TrackingHistorySection({
    super.key,
    required this.trackingHistory,
    required this.isLoading,
    required this.onTrackAgain,
    required this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recently Tracked',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (trackingHistory.isNotEmpty)
              TextButton(
                onPressed: onClearHistory,
                child: const Text('Clear History'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (trackingHistory.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'No tracking history yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: trackingHistory.length,
              itemBuilder: (context, index) {
                final item = trackingHistory[index];
                return TrackingHistoryItem(
                  item: item,
                  onTap: onTrackAgain,
                );
              },
            ),
          ),
      ],
    );
  }
}