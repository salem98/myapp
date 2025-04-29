import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _loadingController;
  late Animation<double> _planeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    
    // Animation for the airplane position
    _planeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        // Use a curve that starts slow, speeds up, then slows down at the end
        curve: Curves.easeInOutCubic,
      ),
    );
    
    _fadeController.forward();
    _scaleController.forward();
    _loadingController.forward();
    
    _loadingController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeController, _scaleController, _loadingController]),
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with fade and scale animation
                AnimatedOpacity(
                  opacity: _fadeController.value,
                  duration: const Duration(milliseconds: 500),
                  child: AnimatedScale(
                    scale: 0.8 + (_scaleController.value * 0.2),
                    duration: const Duration(milliseconds: 500),
                    child: Image.asset(
                      'assets/images/logo-main.png',
                      width: 200,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                const SizedBox(height: 50),
                
                // Airplane loading animation
                AnimatedOpacity(
                  opacity: _fadeController.value,
                  duration: const Duration(milliseconds: 800),
                  child: Container(
                    width: 240,
                    height: 40,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Stack(
                      children: [
                        // Track line
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 18,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                        
                        // Progress line
                        Positioned(
                          left: 0,
                          top: 18,
                          child: Container(
                            width: 240 * _loadingController.value,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE31E24), Color(0xFFFF4D4D)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                        
                        // Airplane icon
                        Positioned(
                          left: (240 * _planeAnimation.value) - 12, // Center the plane on the progress line
                          top: 0,
                          child: Transform.rotate(
                            angle: math.pi / 2, // 90 degrees - point to 3 o'clock (right)
                            child: Icon(
                              Icons.flight,
                              color: const Color(0xFFE31E24),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Loading text with percentage
                AnimatedOpacity(
                  opacity: _fadeController.value,
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    '${(_loadingController.value * 100).toInt()}%',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}