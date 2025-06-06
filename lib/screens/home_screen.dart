import 'package:flutter/material.dart';
import 'package:myapp/screens/tracking_screen.dart';
import 'package:myapp/screens/main_navigation_screen.dart';
import 'package:myapp/widgets/marquee_widget.dart';
import 'package:myapp/widgets/animated_logistics_bottom_bar.dart';
import 'package:myapp/widgets/optimized_carousel.dart';
import 'package:myapp/widgets/quick_actions_section.dart';
import 'dart:async';
import 'package:myapp/services/notification_service.dart';
import 'package:myapp/screens/cost_estimate_screen.dart';

// Custom painter for drawing dashed line
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A8A).withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 5;
    double startX = 0;
    final path = Path();

    // Create a curved path
    path.moveTo(0, size.height / 2);
    path.quadraticBezierTo(
      size.width / 2, 0,
      size.width, size.height / 2,
    );

    // Convert the path to a dashed path
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      double distance = 0;
      bool draw = true;
      while (distance < pathMetric.length) {
        final extractPath = pathMetric.extractPath(
          distance,
          distance + (draw ? dashWidth : dashSpace),
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
        draw = !draw;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated airplane widget with continuous loop
class AnimatedAirplane extends StatefulWidget {
  const AnimatedAirplane({Key? key}) : super(key: key);

  @override
  State<AnimatedAirplane> createState() => _AnimatedAirplaneState();
}

class _AnimatedAirplaneState extends State<AnimatedAirplane> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create an animation controller with a 10-second duration
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Create a tween animation that goes from -100 to 400
    _animation = Tween<double>(begin: -100, end: 400).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    // Add a status listener to repeat the animation when it completes
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: 30 - (_animation.value * 0.05),
          left: _animation.value,
          child: Transform.rotate(
            angle: 1.25, // Approximately 60 degrees more rotation (clockwise)
            child: Icon(
              Icons.flight, // This icon naturally points to the right
              size: 30, // Reduced from 36 to 30
              color: Color(0xFF1E3A8A).withOpacity(0.7),
            ),
          ),
        );
      },
    );
  }
}

// Animated package with continuous bounce
class AnimatedPackage extends StatefulWidget {
  const AnimatedPackage({Key? key}) : super(key: key);

  @override
  State<AnimatedPackage> createState() => _AnimatedPackageState();
}

class _AnimatedPackageState extends State<AnimatedPackage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create an animation controller with a 1-second duration
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create a tween animation for the bounce effect
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        // Use an elastic curve for a bouncy effect
        curve: Curves.easeInOut,
      ),
    );

    // Make the animation repeat in reverse
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          bottom: 30 + (_animation.value * 8), // Bounce up and down by 8 pixels
          left: 40,
          child: Row(
            children: [
              Icon(
                Icons.inventory_2,
                size: 24, // Reduced from 28 to 24
                color: Color(0xFF1E3A8A),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.local_shipping_outlined,
                size: 20, // Reduced from 24 to 20
                color: Color(0xFF1E3A8A).withOpacity(0.6),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool hideBottomBar;

  const HomeScreen({
    super.key,
    this.hideBottomBar = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controller for the banner carousel
  final _bannerController = PageController();

  // Current page index for the banner
  int _currentBannerIndex = 0;

  // Selected shipping option (0 = HK/Macau/Taiwan, 1 = International)
  int _selectedShippingOption = 0;

  // Text controller for tracking number input
  final TextEditingController _trackingNumberController = TextEditingController();
  // Notification service instance
  final _notificationService = NotificationService();

  // List of notifications for marquee and current index
  List<Map<String, dynamic>> _marqueeNotifications = [];
  int _currentMarqueeIndex = 0;
  Timer? _marqueeTextTimer;
  
  // Scroll controller to track scroll position for logo animation
  final ScrollController _scrollController = ScrollController();
  
  // Logo size that will be animated based on scroll position
  double _logoSize = 42;
  double _maxLogoSize = 42;
  double _minLogoSize = 28;

  // Method to handle package tracking with Material 3 styling
  void _trackPackage() {
    final trackingNumber = _trackingNumberController.text.trim();
    if (trackingNumber.isEmpty) {
      // Show a Material 3 styled snackbar if no tracking number is entered
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a tracking number'),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
          showCloseIcon: true,
          closeIconColor: Theme.of(context).colorScheme.onErrorContainer,
          action: SnackBarAction(
            label: 'OK',
            textColor: Theme.of(context).colorScheme.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
      return;
    }

    // Debug message to verify the tracking number
    print("HomeScreen: Tracking package with number: $trackingNumber");
    
    // Show a snackbar to indicate we're processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tracking package: $trackingNumber'),
        duration: const Duration(seconds: 1),
      ),
    );

    // DIRECT NAVIGATION - Always navigate directly to the tracking screen
    print("HomeScreen: Navigating directly to TrackingScreen");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackingScreen(trackingNumber: trackingNumber),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Auto-scroll the banner carousel
    Future.delayed(const Duration(milliseconds: 500), () {
      _startBannerAutoScroll();
    });

    // load existing notifications for marquee
    _notificationService.getAllNotifications().then((data) {
      setState(() {
        _marqueeNotifications = data;
      });
      if (_marqueeNotifications.length > 1) {
        _marqueeTextTimer = Timer.periodic(
          const Duration(seconds: 8),
          (_) {
            setState(() {
              _currentMarqueeIndex =
                  (_currentMarqueeIndex + 1) % _marqueeNotifications.length;
            });
          },
        );
      }
    });
    
    // Add listener to scroll controller for logo animation
    _scrollController.addListener(_updateLogoSize);
  }
  
  // Update logo size based on scroll position
  void _updateLogoSize() {
    final scrollOffset = _scrollController.offset;
    // Calculate new logo size based on scroll position with improved animation curve
    // The logo will shrink as the user scrolls down, with a more natural feel
    final newSize = (_maxLogoSize - (scrollOffset * 0.08)).clamp(_minLogoSize, _maxLogoSize);
    
    if (newSize != _logoSize) {
      setState(() {
        _logoSize = newSize;
      });
    }
  }

  // Auto-scroll function for the banner
  void _startBannerAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_bannerController.hasClients) {
        if (_currentBannerIndex < 1) {
          _bannerController.animateToPage(
            _currentBannerIndex + 1,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        } else {
          _bannerController.animateToPage(
            0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
  }

  // Timer for auto-scrolling
  Timer? _autoScrollTimer;

  @override
  void dispose() {
    _tabController.dispose();
    _bannerController.dispose();
    _trackingNumberController.dispose();
    _scrollController.removeListener(_updateLogoSize);
    _scrollController.dispose();
    _autoScrollTimer?.cancel();
    _marqueeTextTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          scrolledUnderElevation: 0, // No elevation when scrolled under
          elevation: 0,
          toolbarHeight: 60,
          centerTitle: true,
          title: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            height: _logoSize,
            child: Image.asset(
              'assets/images/logo-main.png',
              fit: BoxFit.contain,
            ),
          ),
          // Simplified actions - only essential icons
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, size: 22),
              onPressed: () {},
              tooltip: 'Scan QR Code',
            ),
          ],
          // Add a subtle bottom border for visual separation
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: Theme.of(context).dividerColor.withOpacity(0.1),
            ),
          ),
        ),
        body: SingleChildScrollView(
          controller: _scrollController, // Add scroll controller
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Modern Tracking Section with Grab-inspired design
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmallScreen = constraints.maxWidth < 400;

                  return Column(
                    children: [
                      // Simple News ticker with cleaner design
                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MarqueeWidget(
                                text: _marqueeNotifications.isNotEmpty
                                    ? _marqueeNotifications[_currentMarqueeIndex]['message'] as String
                                    : 'Đang chờ thông báo',
                                textStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w400,
                                  fontSize: isSmallScreen ? 12 : 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Clean Minimal Tracking Bar inspired by Grab
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _trackingNumberController,
                          decoration: InputDecoration(
                            hintText: 'Enter tracking number',
                            hintStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(left: 12, right: 8),
                              child: Icon(
                                Icons.search,
                                size: 20,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            suffixIcon: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_forward,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                onPressed: _trackPackage,
                                tooltip: 'Track Package',
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          onSubmitted: (value) {
                            _trackPackage();
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Spacer
            const SizedBox(height: 8),

            // Optimized Banner Carousel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OptimizedCarousel(
                height: 180, // Reduced from 220 to 140
                items: [
                  // First Banner
                  CarouselItem(
                    title: 'Gửi hàng đi Singapore',
                    subtitle: 'Nhanh chóng • Tiết kiệm • Đảm bảo',
                    buttonText: 'Learn More',
                    onButtonPressed: () {},
                    // Using a solid color instead of an image to avoid loading issues
                    backgroundImageUrl: '',
                    gradientColors: [
                      Colors.blue.shade700.withOpacity(0.8),
                      Colors.blue.shade500.withOpacity(0.3),
                    ],
                    buttonColor: Colors.blue.shade700,
                    rightSideWidget: Container(
                      width: 80, // Reduced from 120 to 80
                      height: 80, // Reduced from 120 to 80
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flight_takeoff,
                        size: 40, // Reduced from 60 to 40
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Second Banner
                  CarouselItem(
                    title: 'New Routes to Asia',
                    subtitle: 'Faster shipping to Japan, Korea, and China',
                    buttonText: 'Explore',
                    onButtonPressed: () {},
                    // Using a solid color instead of an image to avoid loading issues
                    backgroundImageUrl: '',
                    gradientColors: [
                      Colors.indigo.shade700.withOpacity(0.8),
                      Colors.indigo.shade500.withOpacity(0.3),
                    ],
                    buttonColor: Colors.indigo.shade700,
                    rightSideWidget: Container(
                      width: 80, // Reduced from 120 to 80
                      height: 80, // Reduced from 120 to 80
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.public,
                        size: 40, // Reduced from 60 to 40
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
                indicatorActiveColor: Colors.white,
                indicatorInactiveColor: Colors.white.withOpacity(0.5),
                enableAnimation: true,
                autoPlayInterval: const Duration(seconds: 5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            // Material 3 Services Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Determine if we're on a small screen
                  final isSmallScreen = constraints.maxWidth < 400;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Service Types',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 18 : 22,
                            ),
                          ),
                          // Material 3 styled chip
                          ActionChip(
                            avatar: Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            label: Text(
                              'Compare',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Service Type Cards with Material 3 styling
                      SizedBox(
                        height: 120,
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: _selectedShippingOption == 0
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                    width: _selectedShippingOption == 0 ? 2 : 1,
                                  ),
                                ),
                                color: _selectedShippingOption == 0
                                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2)
                                    : Theme.of(context).colorScheme.surface,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedShippingOption = 0;
                                    });
                                    
                                    // Navigate to cost estimate screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CostEstimateScreen(
                                          shippingOption: 0,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primaryContainer,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.flight_takeoff,
                                            color: Theme.of(context).colorScheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                isSmallScreen ? 'AIR' : 'SHIP QUỐC TẾ - INTERNATIONAL',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isSmallScreen ? 14 : 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Express shipping to Southeast Asia & Middle East',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: isSmallScreen ? 11 : 12,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Card(
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: _selectedShippingOption == 1
                                        ? Theme.of(context).colorScheme.secondary
                                        : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                                    width: _selectedShippingOption == 1 ? 2 : 1,
                                  ),
                                ),
                                color: _selectedShippingOption == 1
                                    ? Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2)
                                    : Theme.of(context).colorScheme.surface,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedShippingOption = 1;
                                    });
                                    
                                    // Navigate to cost estimate screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CostEstimateScreen(
                                          shippingOption: 1,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.secondaryContainer,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.public,
                                            color: Theme.of(context).colorScheme.secondary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Mua hộ Shopee/Lazada',
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: isSmallScreen ? 14 : 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Mua hộ 2 chiều các nước',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: isSmallScreen ? 11 : 12,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Modern Quick Actions Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: QuickActionsSection(),
            ),

            // Material 3 Bottom Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Determine if we're on a small screen
                  final isSmallScreen = constraints.maxWidth < 400;

                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.7),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.support_agent,
                              color: Theme.of(context).colorScheme.tertiary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Order Assistant',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isSmallScreen
                                      ? 'Need help with your order? Contact us'
                                      : 'Need help with your order? Our customer service is here to help',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            onPressed: () {},
                            color: Theme.of(context).colorScheme.onTertiaryContainer,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    // Return either just the content or wrapped with AnimatedLogisticsBottomBar
    if (widget.hideBottomBar) {
      return content;
    } else {
      return AnimatedLogisticsBottomBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 2) {
            // Navigate to the tracking screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TrackingScreen(),
              ),
            );
          }
        },
        onCreatePressed: () {
          // Show a snackbar to indicate the action
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Creating new shipment'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
        child: content,
      );
    }
  }

  // Removed _buildDynamicBannerItem method as we're now using the optimized carousel

  // Removed _buildBannerItem method as we're now using the optimized carousel

}
