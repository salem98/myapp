import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ShipmentType {
  air,
  sea,
}

class ShipmentCreationScreen extends StatefulWidget {
  final ShipmentType initialShipmentType;

  const ShipmentCreationScreen({
    Key? key,
    required this.initialShipmentType,
  }) : super(key: key);

  @override
  State<ShipmentCreationScreen> createState() => _ShipmentCreationScreenState();
}

class _ShipmentCreationScreenState extends State<ShipmentCreationScreen> {
  late ShipmentType _selectedShipmentType;
  final _formKey = GlobalKey<FormState>();
  
  // Current step in the form
  int _currentStep = 0;
  
  // Controllers for form fields
  final _senderNameController = TextEditingController();
  final _senderEmailController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  
  final _receiverNameController = TextEditingController();
  final _receiverEmailController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  
  final _packageDescriptionController = TextEditingController();
  final _weightController = TextEditingController();
  
  // Package type
  String _packageType = 'Box';
  final List<String> _packageTypes = ['Box', 'Envelope', 'Pallet', 'Other'];
  
  // Delivery priority
  String _deliveryPriority = 'Standard';
  final List<String> _deliveryPriorities = ['Economy', 'Standard', 'Express', 'Priority'];
  
  // Insurance
  bool _includeInsurance = false;
  
  @override
  void initState() {
    super.initState();
    _selectedShipmentType = widget.initialShipmentType;
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _senderEmailController.dispose();
    _senderPhoneController.dispose();
    
    _receiverNameController.dispose();
    _receiverEmailController.dispose();
    _receiverPhoneController.dispose();
    
    _packageDescriptionController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Create ${_selectedShipmentType == ShipmentType.air ? 'Air' : 'Sea'} Shipment'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: List.generate(
                  4,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Step title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_currentStep + 1}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _getStepTitle(_currentStep),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: _buildStepContent(_currentStep),
                  ),
                ),
              ),
            ),
            
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  if (_currentStep > 0)
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 100), // Placeholder for alignment
                  
                  // Next/Submit button
                  FilledButton.icon(
                    onPressed: () {
                      if (_currentStep < 3) {
                        // Validate current step before proceeding
                        if (_validateCurrentStep()) {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      } else {
                        // Final step - submit the form
                        if (_formKey.currentState!.validate()) {
                          _submitForm();
                        }
                      }
                    },
                    icon: Icon(_currentStep < 3 ? Icons.arrow_forward : Icons.check),
                    label: Text(_currentStep < 3 ? 'Next' : 'Submit'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  // Get the title for the current step
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Shipment Type';
      case 1:
        return 'Sender Details';
      case 2:
        return 'Receiver Details';
      case 3:
        return 'Package Details';
      default:
        return '';
    }
  }

  // Validate the current step
  bool _validateCurrentStep() {
    // Simple validation for demo purposes
    return true;
  }

  // Submit the form
  void _submitForm() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      
      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Shipment Created'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ).animate().scale(
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your shipment has been created successfully!',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tracking Number: SF${DateTime.now().millisecondsSinceEpoch.toString().substring(5, 13)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  // Build the content for the current step
  Widget _buildStepContent(int step) {
    switch (step) {
      case 0:
        return _buildShipmentTypeStep();
      case 1:
        return _buildSenderDetailsStep();
      case 2:
        return _buildReceiverDetailsStep();
      case 3:
        return _buildPackageDetailsStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Shipment Type
  Widget _buildShipmentTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const ValueKey('step1'),
      children: [
        Text(
          'Select your preferred shipping method:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        
        // Shipment type cards
        Row(
          children: [
            Expanded(
              child: _buildShipmentTypeCard(
                ShipmentType.air,
                'Air Shipment',
                'Faster delivery time',
                Icons.flight_takeoff_rounded,
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildShipmentTypeCard(
                ShipmentType.sea,
                'Sea Shipment',
                'Cost-effective for bulk',
                Icons.directions_boat_rounded,
                Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Delivery priority
        Text(
          'Delivery Priority:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _deliveryPriorities.map((priority) {
            return ChoiceChip(
              label: Text(priority),
              selected: _deliveryPriority == priority,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _deliveryPriority = priority;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // Step 2: Sender Details
  Widget _buildSenderDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const ValueKey('step2'),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sender Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Name field
                TextFormField(
                  controller: _senderNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Email field
                TextFormField(
                  controller: _senderEmailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Phone field
                TextFormField(
                  controller: _senderPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Step 3: Receiver Details
  Widget _buildReceiverDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const ValueKey('step3'),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_pin_circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Receiver Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Name field
                TextFormField(
                  controller: _receiverNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Email field
                TextFormField(
                  controller: _receiverEmailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                
                // Phone field
                TextFormField(
                  controller: _receiverPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Step 4: Package Details
  Widget _buildPackageDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: const ValueKey('step4'),
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Package Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Package type
                Text(
                  'Package Type:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _packageTypes.map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _packageType == type,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _packageType = type;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                
                // Description field
                TextFormField(
                  controller: _packageDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Package Description',
                    prefixIcon: const Icon(Icons.description_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Weight field
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: const Icon(Icons.scale_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                
                // Insurance option
                SwitchListTile(
                  title: const Text('Include Insurance'),
                  subtitle: const Text('Protect your package against loss or damage'),
                  value: _includeInsurance,
                  onChanged: (value) {
                    setState(() {
                      _includeInsurance = value;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Estimated price card
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimated Price',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Base Shipping:'),
                    Text(
                      '\$${_selectedShipmentType == ShipmentType.air ? '120.00' : '80.00'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Insurance:'),
                    Text(
                      _includeInsurance ? '\$15.00' : '\$0.00',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:'),
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Calculate total price
  double _calculateTotal() {
    double basePrice = _selectedShipmentType == ShipmentType.air ? 120.0 : 80.0;
    double insurancePrice = _includeInsurance ? 15.0 : 0.0;
    return basePrice + insurancePrice;
  }

  // Build a shipment type card
  Widget _buildShipmentTypeCard(
    ShipmentType type,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedShipmentType == type;
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? color : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      color: isSelected ? color.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedShipmentType = type;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                color: color,
                size: 32,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}