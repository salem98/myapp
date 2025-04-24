import 'package:flutter/material.dart';
import 'dart:async';

class BannerCarousel extends StatefulWidget {
  final List<BannerItem> items;
  final double height;
  final Duration autoPlayInterval;
  final bool showIndicator;
  final Color indicatorActiveColor;
  final Color indicatorInactiveColor;

  const BannerCarousel({
    super.key,
    required this.items,
    this.height = 140, // Reduced from 180 to 140
    this.autoPlayInterval = const Duration(seconds: 5),
    this.showIndicator = true,
    this.indicatorActiveColor = Colors.white,
    this.indicatorInactiveColor = Colors.white54,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPlay();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (_currentPage < widget.items.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: widget.items[index],
              );
            },
          ),
          if (widget.showIndicator)
            Positioned(
              bottom: 8, // Reduced from 16 to 8
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.items.length,
                  (index) => Container(
                    width: 6, // Reduced from 8 to 6
                    height: 6, // Reduced from 8 to 6
                    margin: const EdgeInsets.symmetric(horizontal: 3), // Reduced from 4 to 3
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? widget.indicatorActiveColor
                          : widget.indicatorInactiveColor,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BannerItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String backgroundImageUrl;
  final List<Color> gradientColors;
  final Widget? rightSideWidget;

  const BannerItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    required this.backgroundImageUrl,
    this.gradientColors = const [Colors.black54, Colors.transparent],
    this.rightSideWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(backgroundImageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: const EdgeInsets.all(12), // Reduced from 20 to 12
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18, // Reduced from 24 to 18
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1, // Limit to one line
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // Reduced from 8 to 4
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12, // Reduced from 16 to 12
                    color: Colors.white,
                  ),
                  maxLines: 1, // Limit to one line
                  overflow: TextOverflow.ellipsis,
                ),
                if (buttonText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8), // Reduced from 16 to 8
                    child: ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, // Reduced from 20 to 12
                          vertical: 8, // Reduced from 12 to 8
                        ),
                      ),
                      child: Text(
                        buttonText!,
                        style: const TextStyle(fontSize: 12), // Smaller text
                      ),
                    ),
                  ),
              ],
            ),
            if (rightSideWidget != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: rightSideWidget!,
              ),
          ],
        ),
      ),
    );
  }
}
