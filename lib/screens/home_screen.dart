import 'package:flutter/material.dart';
import 'package:myapp/screens/tracking_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:myapp/widgets/optimized_carousel.dart';
import 'package:myapp/widgets/marquee_widget.dart';
import 'dart:async';
import 'dart:math' as math;

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
  const HomeScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Auto-scroll the banner carousel
    Future.delayed(const Duration(milliseconds: 500), () {
      _startBannerAutoScroll();
    });
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
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Image.asset(
            'assets/images/logo-main.png',
            height: 40,
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modern Tracking Bar with Airplane Animation
            Stack(
              children: [
                // Background with animated airplane
                Container(
                  height: 150, // Reduced from 180 to 150
                  margin: const EdgeInsets.fromLTRB(20, 16, 20, 8), // Reduced vertical margins
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        // Background gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFF0F4FF),
                                Colors.white,
                              ],
                            ),
                          ),
                        ),
                        // Animated airplane with continuous loop
                        AnimatedAirplane(),
                        // Animated package with continuous bounce
                        AnimatedPackage(),
                        // Dotted path for airplane
                        Positioned(
                          top: 15, // Reduced from 20 to 15
                          left: 0,
                          right: 0,
                          child: CustomPaint(
                            size: const Size(double.infinity, 50), // Reduced from 60 to 50
                            painter: DashedLinePainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // News ticker - running text from right to left
                Positioned(
                  left: 20,
                  right: 20,
                  top: 10, // Reduced from 15 to 10
                  child: Container(
                    height: 24, // Reduced from 30 to 24
                    decoration: BoxDecoration(
                      color: Color(0xFF1E3A8A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12), // Reduced from 15 to 12
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12), // Reduced from 15 to 12
                      child: MarqueeWidget(
                        text: "Đây là thông báo thử nghiệm - Chúng tôi đang nâng cấp hệ thống - Xin cảm ơn quý khách đã sử dụng dịch vụ",
                        textStyle: TextStyle(
                          color: Color(0xFF1E3A8A),
                          fontWeight: FontWeight.w500,
                          fontSize: 12, // Reduced from 13 to 12
                        ),
                      ),
                    ),
                  ),
                ),

                // Tracking input field
                Positioned(
                  left: 40,
                  right: 40,
                  top: 50, // Reduced from 65 to 50
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10, // Reduced from 15 to 10
                          offset: const Offset(0, 3), // Reduced from 5 to 3
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _trackingNumberController,
                            decoration: InputDecoration(
                              hintText: 'Enter tracking number',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced from 16 to 12
                              prefixIcon: Icon(
                                Icons.search,
                                color: Color(0xFF1E3A8A).withOpacity(0.7),
                                size: 20,
                              ),
                            ),
                            onSubmitted: (value) {
                              _trackPackage();
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 6), // Reduced from 8 to 6
                          decoration: BoxDecoration(
                            color: Color(0xFF1E3A8A),
                            borderRadius: BorderRadius.circular(6), // Reduced from 8 to 6
                          ),
                          child: IconButton(
                            onPressed: _trackPackage,
                            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 18), // Reduced from 20 to 18
                            tooltip: 'Track package',
                            padding: EdgeInsets.all(8), // Add smaller padding
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Divider(color: Colors.grey.shade200, height: 20),
            ),

            // Optimized Banner Carousel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: OptimizedCarousel(
                height: 140, // Reduced from 220 to 140
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

            // Services Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service Types',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Compare',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Service Type Cards with consistent sizing
                  SizedBox(
                    height: 120, // Reduced from 140 to 120
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildShippingOptionCard(
                            title: 'Singapore, Malaysia, Dubai',
                            subtitle: 'Express shipping to Southeast Asia & Middle East',
                            icon: Icons.flight_takeoff,
                            accentColor: Colors.green,
                            isSelected: _selectedShippingOption == 0,
                            onTap: () {
                              setState(() {
                                _selectedShippingOption = 0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildShippingOptionCard(
                            title: 'International',
                            subtitle: 'Shipping to over 200+ countries worldwide',
                            icon: Icons.public,
                            accentColor: Colors.blue,
                            isSelected: _selectedShippingOption == 1,
                            onTap: () {
                              setState(() {
                                _selectedShippingOption = 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 3.0, // Increased from 2.5 to 3.0 for more compact cards
                    mainAxisSpacing: 8, // Reduced from 12 to 8
                    crossAxisSpacing: 8, // Reduced from 12 to 8
                    children: [
                      _buildQuickAction(Icons.language, 'International Routes', tag: 'Best Value'),
                      _buildQuickAction(Icons.search, 'Track Package', onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TrackingScreen(),
                          ),
                        );
                      }),
                      _buildQuickAction(Icons.access_time, 'Delivery Time'),
                      _buildQuickAction(Icons.rule, 'Shipping Standards'),
                      _buildQuickAction(Icons.map, 'Coverage Area'),
                      _buildQuickAction(Icons.straighten, 'Measurement Rules'),
                      _buildQuickAction(Icons.info_outline, 'Product Info'),
                      _buildQuickAction(Icons.business, 'Enterprise Registration', tag: 'New'),
                    ],
                  ),
                ],
              ),
            ),

            // Bottom Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Reduced vertical margin
              padding: const EdgeInsets.all(12), // Reduced from 16 to 12
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    color: Colors.orange.shade800,
                    size: 28, // Reduced from 32 to 28
                  ),
                  const SizedBox(width: 12), // Reduced from 16 to 12
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Assistant',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Need help with your order? Our customer service is here to help',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Track',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Account',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TrackingScreen(),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, {String? tag, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  icon,
                  size: 24, // Reduced from 28 to 24
                  color: Colors.blue.shade700,
                ),
                if (tag != null)
                  Positioned(
                    right: -3, // Reduced from -5 to -3
                    top: -3, // Reduced from -5 to -3
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1), // Reduced padding
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6), // Reduced from 8 to 6
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6), // Reduced from 8 to 6
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to handle package tracking
  void _trackPackage() {
    final trackingNumber = _trackingNumberController.text.trim();
    if (trackingNumber.isEmpty) {
      // Show a snackbar if no tracking number is entered
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a tracking number'),
          backgroundColor: Color(0xFF1E3A8A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: EdgeInsets.all(16),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to tracking screen with the tracking number
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrackingScreen(trackingNumber: trackingNumber),
      ),
    );
  }

  // Removed _buildDynamicBannerItem method as we're now using the optimized carousel

  // Removed _buildBannerItem method as we're now using the optimized carousel

  Widget _buildShippingOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Use shorter text for specific titles to ensure they fit on mobile
    String displayTitle = title;
    String displaySubtitle = subtitle;

    // Only modify the Singapore text which is too long
    if (title == 'Singapore, Malaysia, Dubai') {
      displayTitle = 'AIR';
      displaySubtitle = 'Express shipping to Singapore, Malaysia & Dubai';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // Reduced from 24 to 16
      child: Container(
        height: 120, // Reduced from 140 to 120
        padding: const EdgeInsets.all(12), // Reduced from 16 to 12
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // Reduced from 24 to 16
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
          boxShadow: [
            // Outer shadow (darker on bottom-right)
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8, // Reduced from 10 to 8
              offset: const Offset(5, 5),
              spreadRadius: 1,
            ),
            // Inner shadow (lighter on top-left) - neumorphic effect
            BoxShadow(
              color: Colors.white,
              blurRadius: 8, // Reduced from 10 to 8
              offset: const Offset(-3, -3),
              spreadRadius: 1,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              accentColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background decorative circle
            Positioned(
              right: -10, // Reduced from -15 to -10
              top: -10, // Reduced from -15 to -10
              child: Container(
                width: 50, // Reduced from 70 to 50
                height: 50, // Reduced from 70 to 50
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon with glass effect
                Container(
                  width: 40, // Reduced from 50 to 40
                  height: 40, // Reduced from 50 to 40
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12), // Reduced from 16 to 12
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: accentColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 20, // Reduced from 24 to 20
                  ),
                ),
                const SizedBox(width: 8), // Reduced from 12 to 8
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayTitle,
                        style: TextStyle(
                          fontSize: 14, // Reduced from 15 to 14
                          fontWeight: FontWeight.bold,
                          color: isSelected ? accentColor : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2), // Reduced from 4 to 2
                      Text(
                        displaySubtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Selection indicator
            if (isSelected)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20, // Reduced from 24 to 20
                  height: 20, // Reduced from 24 to 20
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14, // Reduced from 16 to 14
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
