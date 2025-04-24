import 'package:flutter/material.dart';
import 'dart:async';

class OptimizedCarousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final Duration autoPlayInterval;
  final bool showIndicator;
  final Color indicatorActiveColor;
  final Color indicatorInactiveColor;
  final double indicatorSize;
  final double indicatorSpacing;
  final bool enableAnimation;
  final Curve animationCurve;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const OptimizedCarousel({
    super.key,
    required this.items,
    this.height = 180,
    this.autoPlayInterval = const Duration(seconds: 5),
    this.showIndicator = true,
    this.indicatorActiveColor = Colors.white,
    this.indicatorInactiveColor = Colors.white54,
    this.indicatorSize = 8.0,
    this.indicatorSpacing = 8.0,
    this.enableAnimation = true,
    this.animationCurve = Curves.easeInOut,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.padding = EdgeInsets.zero,
  });

  @override
  State<OptimizedCarousel> createState() => _OptimizedCarouselState();
}

class _OptimizedCarouselState extends State<OptimizedCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    if (widget.enableAnimation) {
      _startAutoPlay();
    }
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
          curve: widget.animationCurve,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      padding: widget.padding,
      child: Stack(
        children: [
          // Main carousel
          ClipRRect(
            borderRadius: widget.borderRadius,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return widget.items[index];
              },
            ),
          ),
          
          // Custom animated dot indicators
          if (widget.showIndicator)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == index 
                        ? widget.indicatorSize * 2 
                        : widget.indicatorSize,
                    height: widget.indicatorSize,
                    margin: EdgeInsets.symmetric(horizontal: widget.indicatorSpacing / 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.indicatorSize / 2),
                      color: _currentPage == index
                          ? widget.indicatorActiveColor
                          : widget.indicatorInactiveColor,
                      boxShadow: _currentPage == index 
                          ? [
                              BoxShadow(
                                color: widget.indicatorActiveColor.withOpacity(0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              )
                            ] 
                          : null,
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

class CarouselItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final String backgroundImageUrl;
  final List<Color> gradientColors;
  final Color buttonColor;
  final Color textColor;
  final Widget? rightSideWidget;

  const CarouselItem({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    required this.backgroundImageUrl,
    this.gradientColors = const [Colors.black54, Colors.transparent],
    this.buttonColor = Colors.blue,
    this.textColor = Colors.white,
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
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                if (buttonText != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ElevatedButton(
                      onPressed: onButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: buttonColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        elevation: 4,
                        shadowColor: buttonColor.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(buttonText!),
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
