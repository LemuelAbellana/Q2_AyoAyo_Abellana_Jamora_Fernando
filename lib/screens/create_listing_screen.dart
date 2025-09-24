import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/models/marketplace.dart';
import 'package:ayoayo/models/resell_listing.dart';
import 'package:ayoayo/providers/resell_provider.dart';
import 'package:ayoayo/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  _CreateListingScreenState createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Listing form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  // Device form controllers
  final _deviceModelController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _yearController = TextEditingController();
  final _osController = TextEditingController();

  ConditionGrade _selectedCondition = ConditionGrade.good;
  Marketplace? _selectedMarketplace;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill some common values
    _manufacturerController.text = 'Apple';
    _osController.text = 'iOS';
    _yearController.text = DateTime.now().year.toString();
  }

  @override
  void dispose() {
    _deviceModelController.dispose();
    _manufacturerController.dispose();
    _yearController.dispose();
    _osController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Create New Listing'),
        backgroundColor: AppTheme.surfaceWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: AppTheme.primaryBlue),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    _buildProgressIndicator(),

                    const SizedBox(height: 24),

                    // Device Selection Section
                    _buildSectionHeader(
                      'Select Device',
                      LucideIcons.smartphone,
                      subtitle: 'Choose the device you want to sell',
                    ),
                    const SizedBox(height: 16),
                    _buildDeviceSelection(),

                    const SizedBox(height: 32),

                    // Marketplace Selection Section
                    _buildSectionHeader(
                      'Choose Marketplace',
                      LucideIcons.mapPin,
                      subtitle: 'Where do you want to sell?',
                    ),
                    const SizedBox(height: 16),
                    _buildMarketplaceSelection(),

                    const SizedBox(height: 32),

                    // Listing Details Section
                    _buildSectionHeader(
                      'Listing Details',
                      LucideIcons.fileText,
                      subtitle: 'Tell buyers about your device',
                    ),
                    const SizedBox(height: 16),
                    _buildListingForm(),

                    const SizedBox(height: 40),

                    // Create Button with enhanced styling
                    _buildCreateButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Creating your listing...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildProgressStep('Device', _isDeviceFormValid(), 1),
          _buildProgressConnector(_isDeviceFormValid()),
          _buildProgressStep('Marketplace', _selectedMarketplace != null, 2),
          _buildProgressConnector(_selectedMarketplace != null),
          _buildProgressStep('Details', _isFormValid(), 3),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isCompleted, int step) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppTheme.primaryGreen : Colors.grey[300]!,
              border: Border.all(
                color: isCompleted ? AppTheme.primaryGreen : Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: TextStyle(
                  color: isCompleted ? Colors.white : Colors.grey[600]!,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isCompleted ? AppTheme.primaryGreen : Colors.grey[600]!,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressConnector(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      color: isActive ? AppTheme.primaryGreen : Colors.grey[300],
    );
  }

  bool _isDeviceFormValid() {
    return _deviceModelController.text.trim().isNotEmpty &&
        _manufacturerController.text.trim().isNotEmpty &&
        _yearController.text.trim().isNotEmpty &&
        _osController.text.trim().isNotEmpty;
  }

  bool _isFormValid() {
    return _isDeviceFormValid() &&
        _selectedMarketplace != null &&
        _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty;
  }

  Widget _buildSectionHeader(String title, IconData icon, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(color: AppTheme.textSecondary.withOpacity(0.2), thickness: 1),
      ],
    );
  }

  Widget _buildCreateButton() {
    final isEnabled = _isFormValid();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: isEnabled ? AppTheme.primaryGradient : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ElevatedButton.icon(
        onPressed: isEnabled ? _createListing : null,
        icon: Icon(
          Icons.add,
          size: 24,
          color: isEnabled ? Colors.white : Colors.grey[400],
        ),
        label: Text(
          'Create Listing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isEnabled ? Colors.white : Colors.grey[400],
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text('How to Create a Listing'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                Icons.smartphone,
                'Select Device',
                'Choose from your available devices or add a new one.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                Icons.location_on,
                'Choose Marketplace',
                'Select where you want to sell your device (Facebook, SM Ecoland, etc.).',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                Icons.description,
                'Add Details',
                'Write a compelling title and detailed description. Be honest about condition.',
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                Icons.attach_money,
                'Set Price',
                'Enter your asking price. AI will suggest optimal pricing based on market data.',
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.lightbulb,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tip: Higher quality photos and detailed descriptions sell faster!',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Model
          TextFormField(
            controller: _deviceModelController,
            decoration: InputDecoration(
              labelText: 'Device Model',
              hintText: 'e.g., iPhone 13 Pro, Samsung Galaxy S22',
              prefixIcon: Icon(Icons.smartphone, color: AppTheme.primaryBlue),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the device model';
              }
              if (value.trim().length < 2) {
                return 'Device model must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Manufacturer
          TextFormField(
            controller: _manufacturerController,
            decoration: InputDecoration(
              labelText: 'Manufacturer',
              hintText: 'e.g., Apple, Samsung, Google',
              prefixIcon: Icon(Icons.business, color: AppTheme.primaryBlue),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the manufacturer';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Year of Release
          TextFormField(
            controller: _yearController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Year of Release',
              hintText: 'e.g., 2022',
              prefixIcon: Icon(
                Icons.calendar_today,
                color: AppTheme.primaryBlue,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the year of release';
              }
              final year = int.tryParse(value);
              if (year == null) {
                return 'Please enter a valid year';
              }
              final currentYear = DateTime.now().year;
              if (year < 2000 || year > currentYear + 1) {
                return 'Please enter a valid year (2000-${currentYear + 1})';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Operating System
          TextFormField(
            controller: _osController,
            decoration: InputDecoration(
              labelText: 'Operating System',
              hintText: 'e.g., iOS, Android, Windows',
              prefixIcon: Icon(
                Icons.settings_system_daydream,
                color: AppTheme.primaryBlue,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the operating system';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Device Preview
          if (_deviceModelController.text.isNotEmpty &&
              _manufacturerController.text.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_deviceModelController.text.trim()} by ${_manufacturerController.text.trim()}',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMarketplaceSelection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          if (_selectedMarketplace != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    _selectedMarketplace!.type == 'online'
                        ? Icons.language
                        : Icons.location_on,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedMarketplace!.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        _selectedMarketplace!.description,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _showMarketplaceSelectionDialog,
                  icon: const Icon(LucideIcons.chevronDown),
                ),
              ],
            ),
          ] else ...[
            ListTile(
              onTap: _showMarketplaceSelectionDialog,
              leading: Icon(Icons.location_on, color: AppTheme.primaryBlue),
              title: Text(
                'Choose marketplace',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Facebook, SM Ecoland, etc.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              trailing: Icon(Icons.chevron_right, color: AppTheme.primaryBlue),
              tileColor: AppTheme.primaryBlue.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListingForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Listing Title',
              hintText: 'e.g., "iPhone 13 Pro 256GB - Like New"',
              prefixIcon: Icon(Icons.title, color: AppTheme.primaryBlue),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              if (value.length < 10) {
                return 'Title should be at least 10 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText:
                  'Describe your device condition, features, and any additional details',
              prefixIcon: Icon(Icons.description, color: AppTheme.primaryBlue),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              if (value.length < 20) {
                return 'Description should be at least 20 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Asking Price (₱)',
              hintText: 'Enter your asking price',
              prefixIcon: Icon(
                Icons.attach_money,
                color: AppTheme.primaryGreen,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a price';
              }
              final price = double.tryParse(value);
              if (price == null || price <= 0) {
                return 'Please enter a valid price';
              }
              if (price < 100) {
                return 'Price should be at least ₱100';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ConditionGrade>(
            value: _selectedCondition,
            onChanged: (value) {
              setState(() {
                _selectedCondition = value!;
              });
            },
            decoration: InputDecoration(
              labelText: 'Device Condition',
              prefixIcon: Icon(Icons.star, color: AppTheme.primaryBlue),
            ),
            items: ConditionGrade.values.map((condition) {
              return DropdownMenuItem(
                value: condition,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getConditionColor(condition),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_getConditionDisplayName(condition)),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Form validation status
          if (_titleController.text.trim().isNotEmpty &&
              _descriptionController.text.trim().isNotEmpty &&
              _priceController.text.trim().isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Listing details are complete!',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showMarketplaceSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Marketplace'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: davaoMarketplaces.length,
            itemBuilder: (context, index) {
              final marketplace = davaoMarketplaces[index];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    marketplace.type == 'online'
                        ? LucideIcons.globe
                        : LucideIcons.mapPin,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(marketplace.name),
                subtitle: Text(
                  marketplace.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  setState(() {
                    _selectedMarketplace = marketplace;
                  });
                  Navigator.of(context).pop();
                },
                selected: _selectedMarketplace?.id == marketplace.id,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _createListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isDeviceFormValid()) {
      _showErrorSnackBar('Please fill in all device information');
      return;
    }

    if (_selectedMarketplace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a marketplace')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate price format
      final price = double.tryParse(_priceController.text.trim());
      if (price == null) {
        _showErrorSnackBar('Please enter a valid price');
        return;
      }

      if (price < 100) {
        _showErrorSnackBar('Price must be at least ₱100');
        return;
      }

      if (price > 100000) {
        _showErrorSnackBar('Price cannot exceed ₱100,000');
        return;
      }

      // Create DevicePassport from user input
      final devicePassport = DevicePassport(
        id: 'device_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_1', // In real app, get from auth
        deviceModel: _deviceModelController.text.trim(),
        manufacturer: _manufacturerController.text.trim(),
        yearOfRelease: int.parse(_yearController.text.trim()),
        operatingSystem: _osController.text.trim(),
        imageUrls: [
          'https://via.placeholder.com/300x300?text=${_deviceModelController.text.trim()}',
        ],
        lastDiagnosis: DiagnosisResult(
          deviceModel: _deviceModelController.text.trim(),
          deviceHealth: DeviceHealth(
            batteryHealth: 85, // Default good battery
            screenCondition:
                _selectedCondition == ConditionGrade.excellent ||
                    _selectedCondition == ConditionGrade.good
                ? ScreenCondition.good
                : ScreenCondition.fair,
            hardwareCondition:
                _selectedCondition == ConditionGrade.excellent ||
                    _selectedCondition == ConditionGrade.good
                ? HardwareCondition.good
                : HardwareCondition.fair,
            identifiedIssues: [],
          ),
          valueEstimation: ValueEstimation(
            currentValue: price,
            postRepairValue: price,
            partsValue: 0,
            repairCost: 0,
            recyclingValue: price * 0.2,
            currency: 'PHP',
            marketPositioning: 'User-defined pricing',
            depreciationRate: '15% per year',
          ),
          recommendations: [],
          aiAnalysis:
              'User-defined device with ${_selectedCondition.toString().split('.').last} condition',
          confidenceScore: 0.9,
          imageUrls: [
            'https://via.placeholder.com/300x300?text=${_deviceModelController.text.trim()}',
          ],
        ),
      );

      final success = await context.read<ResellProvider>().createListing(
        devicePassport: devicePassport,
        condition: _selectedCondition,
        askingPrice: price,
        sellerId: '1', // In real app, get from auth
        location: _selectedMarketplace!.name,
        customTitle: _titleController.text.trim(),
        customDescription: _descriptionController.text.trim(),
      );

      if (success) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar(
          'Failed to create listing. Please check your connection and try again.',
        );
      }
    } catch (e) {
      print('Error creating listing: $e');
      if (e.toString().contains('connection') ||
          e.toString().contains('network')) {
        _showErrorSnackBar(
          'Network error. Please check your connection and try again.',
        );
      } else if (e.toString().contains('database') ||
          e.toString().contains('SQLite')) {
        _showErrorSnackBar(
          'Database error. Please try again or contact support.',
        );
      } else {
        _showErrorSnackBar('An unexpected error occurred. Please try again.');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Listing Created Successfully!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your ${_deviceModelController.text.trim()} has been listed on ${_selectedMarketplace!.name}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tip: Share your listing on social media to reach more buyers!',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to marketplace
            },
            child: const Text('View Listings'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Stay on create listing screen to create another
              _resetForm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Create Another'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _selectedCondition = ConditionGrade.good;
      // Keep device and marketplace selected for convenience
    });
  }

  Color _getConditionColor(ConditionGrade condition) {
    switch (condition) {
      case ConditionGrade.excellent:
        return Colors.green;
      case ConditionGrade.good:
        return Colors.blue;
      case ConditionGrade.fair:
        return Colors.orange;
      case ConditionGrade.poor:
        return Colors.red;
      case ConditionGrade.damaged:
        return Colors.grey;
    }
  }

  String _getConditionDisplayName(ConditionGrade condition) {
    switch (condition) {
      case ConditionGrade.excellent:
        return 'Excellent';
      case ConditionGrade.good:
        return 'Good';
      case ConditionGrade.fair:
        return 'Fair';
      case ConditionGrade.poor:
        return 'Poor';
      case ConditionGrade.damaged:
        return 'Damaged';
    }
  }
}
