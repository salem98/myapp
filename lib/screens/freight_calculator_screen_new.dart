import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/freight_models.dart';
import '../widgets/freight_calculator_widgets.dart';

class FreightCalculatorScreen extends StatefulWidget {
  const FreightCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<FreightCalculatorScreen> createState() => _FreightCalculatorScreenState();
}

class _FreightCalculatorScreenState extends State<FreightCalculatorScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final TextEditingController _weightController = TextEditingController(text: '5');
  final TextEditingController _volumeController = TextEditingController(text: '0');
  
  // Dimension controllers for volume calculation
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  
  // Shipping details
  String _fromRegion = 'China Mainland';
  String _toDestination = 'Singapore';
  
  // Available countries
  final List<String> _countries = [
    'China Mainland',
    'Vietnam',
    'Singapore',
    'Dubai',
    'Taiwan',
    'Malaysia',
    'Australia'
  ];
  
  // Package list
  List<Package> _packages = [Package(id: 1, weight: 5, volume: 0)];
  
  // Animation controller for transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // State for showing calculation results
  bool _showResults = false;
  
  // Quick reference volume presets (in cubic meters)
  final Map<String, double> _volumePresets = {
    'A4 book size': 0.001,
    'Ordinary shoe box size': 0.008,
    'Microwave oven size': 0.035,
    'Bedside table size': 0.12,
    'Washing machine size': 0.25,
  };
  
  // Quick reference icons
  final Map<String, IconData> _presetIcons = {
    'A4 book size': Icons.book,
    'Ordinary shoe box size': Icons.shopping_bag,
    'Microwave oven size': Icons.microwave,
    'Bedside table size': Icons.nightlight,
    'Washing machine size': Icons.local_laundry_service,
  };
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _weightController.dispose();
    _volumeController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }
  
  // Calculate total weight and volume
  double get totalWeight => _packages.fold(0, (sum, package) => sum + package.weight);
  double get totalVolume => _packages.fold(0, (sum, package) => sum + package.volume);
  
  // Add a new package
  void _addPackage() {
    setState(() {
      _packages.add(Package(
        id: _packages.isEmpty ? 1 : _packages.last.id + 1,
        weight: 0,
        volume: 0,
      ));
    });
  }
  
  // Remove a package
  void _removePackage(int id) {
    setState(() {
      _packages.removeWhere((package) => package.id == id);
      if (_packages.isEmpty) {
        _addPackage(); // Always have at least one package
      }
      
      // Check if we should hide results
      if (totalWeight <= 0) {
        _showResults = false;
      }
    });
  }
  
  // Update package weight
  void _updatePackageWeight(int id, double weight) {
    final index = _packages.indexWhere((package) => package.id == id);
    if (index != -1) {
      setState(() {
        _packages[index].weight = weight;
        
        // Hide results if total weight is zero
        if (totalWeight <= 0) {
          _showResults = false;
        }
      });
    }
  }
  
  // Update package volume
  void _updatePackageVolume(int id, double volume) {
    final index = _packages.indexWhere((package) => package.id == id);
    if (index != -1) {
      setState(() {
        _packages[index].volume = volume;
      });
    }
  }
  
  // Start calculation
  void _startCalculation() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _showResults = true;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  // Show volume calculation dialog
  void _showVolumeCalculator(int packageId) {
    // Reset dimension controllers
    _lengthController.clear();
    _widthController.clear();
    _heightController.clear();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vol(CBM) - Package #$packageId',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Estimated volume',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Quick Reference',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _volumePresets.entries.map((entry) {
                        return InkWell(
                          onTap: () {
                            // Apply preset volume dimensions
                            setDialogState(() {
                              // Calculate dimensions based on preset volume
                              // Using cubic root to get approximate dimensions
                              double dimension = math.pow(entry.value, 1/3).toDouble() * 100; // Convert to cm
                              _lengthController.text = dimension.toStringAsFixed(1);
                              _widthController.text = dimension.toStringAsFixed(1);
                              _heightController.text = dimension.toStringAsFixed(1);
                              
                              // Show a hint that dimensions are set but confirmation is needed
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Package #$packageId: Dimensions set for ${entry.key}. Click Confirm to apply.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_presetIcons[entry.key] ?? Icons.category, size: 18),
                                const SizedBox(width: 4),
                                Text(entry.key),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Long'),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _lengthController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: 'cm',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('×', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Width'),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _widthController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: 'cm',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('×', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Height'),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: 'cm',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Calculate volume in cubic meters
                          double length = double.tryParse(_lengthController.text) ?? 0;
                          double width = double.tryParse(_widthController.text) ?? 0;
                          double height = double.tryParse(_heightController.text) ?? 0;
                          
                          print("Dimensions: L=$length, W=$width, H=$height");
                          
                          if (length <= 0 || width <= 0 || height <= 0) {
                            // Show error message if dimensions are invalid
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Package #$packageId: Please enter valid dimensions (greater than 0)'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          
                          // Calculate actual volume in cubic meters (L×W×H in cm / 1,000,000)
                          double actualVolume = (length * width * height) / 1000000;
                          print("Actual volume in cubic meters: $actualVolume");
                          
                          // Calculate volumetric weight using logistics standard formula (L×W×H / 6000)
                          // This gives a weight in kg that can be compared to actual weight
                          double volumetricWeight = (length * width * height) / 6000;
                          print("Volumetric weight: $volumetricWeight kg");
                          
                          // Get the actual weight of the package
                          final index = _packages.indexWhere((package) => package.id == packageId);
                          if (index == -1) return;
                          double actualWeight = _packages[index].weight;
                          print("Actual weight: $actualWeight kg");
                          
                          // In logistics, the volume is expressed in cubic meters (L×W×H / 1,000,000)
                          // This is the actual physical volume of the package
                          double volumeInCubicMeters = actualVolume;
                          print("Volume in cubic meters: $volumeInCubicMeters CBM");
                          
                          // For billing, the higher of volumetric weight and actual weight is used
                          String billingNote = "";
                          if (volumetricWeight > actualWeight) {
                            billingNote = "Volumetric weight ($volumetricWeight kg) exceeds actual weight ($actualWeight kg)";
                          } else {
                            billingNote = "Actual weight ($actualWeight kg) exceeds volumetric weight ($volumetricWeight kg)";
                          }
                          print(billingNote);
                          
                          // Update package volume
                          setState(() {
                            // Always set the volume based on the dimensions
                            _packages[index].volume = volumeInCubicMeters;
                            print("Updated package volume: ${_packages[index].volume} m³");
                          });
                          
                          // Show a toast message with complete logistics information
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Package #$packageId:\n'
                                'Volume: ${volumeInCubicMeters.toStringAsFixed(6)} m³\n'
                                'Volumetric weight: ${volumetricWeight.toStringAsFixed(2)} kg\n'
                                '$billingNote'
                              ),
                              duration: Duration(seconds: 4),
                            ),
                          );
                          
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Freight Calculator'),
        backgroundColor: const Color(0xFFADD8E6), // Light blue background
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined),
            onPressed: () {
              // Customer support action
            },
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildInputForm(),
            if (_showResults) _buildResultsView(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FreightCalculatorWidgets.buildWarmTipsSection(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shipping route section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Region',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _fromRegion,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            items: _countries.map((country) {
                              return DropdownMenuItem<String>(
                                value: country,
                                child: Text(
                                  country,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _fromRegion = value;
                                });
                              }
                            },
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward,
                          color: Colors.blue,
                          size: 24,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Destination',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _toDestination,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                items: _countries.map((country) {
                                  return DropdownMenuItem<String>(
                                    value: country,
                                    child: Text(
                                      country,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _toDestination = value;
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Total Weight: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: '${totalWeight.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' KG',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                const TextSpan(
                                  text: 'Total Volume: ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                TextSpan(
                                  text: '${totalVolume.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const TextSpan(
                                  text: ' M³',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Package list
            ..._packages.map((package) => FreightCalculatorWidgets.buildPackageItem(
              package: package,
              updateWeight: _updatePackageWeight,
              updateVolume: _updatePackageVolume,
              removePackage: _removePackage,
              showVolumeCalculator: _showVolumeCalculator,
              canDelete: _packages.length > 1,
            )),
            
            const SizedBox(height: 16),
            
            // Add package button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _addPackage,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Package'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Start calculation button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _startCalculation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Start calculation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  
  Widget _buildResultsView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sea freight section
            FreightCalculatorWidgets.buildFreightSection(
              title: 'Official Gathering-By Sea',
              deliveryType: 'Home Delivery',
              cnyPrice: 280,
              sgdPrice: 50.75,
              packages: _packages.length,
            ),
            
            const SizedBox(height: 24),
            
            // Economy Sea freight section
            FreightCalculatorWidgets.buildFreightSection(
              title: 'Official Gathering-By Economy Sea',
              deliveryType: 'Home Delivery',
              cnyPrice: 280,
              sgdPrice: 50.75,
              packages: _packages.length,
            ),
            
            const SizedBox(height: 24),
            
            // Air freight section (added as an extra option)
            FreightCalculatorWidgets.buildFreightSection(
              title: 'Official Gathering-By Air',
              deliveryType: 'Home Delivery',
              cnyPrice: 560,
              sgdPrice: 101.50,
              packages: _packages.length,
              isHighlighted: true,
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}