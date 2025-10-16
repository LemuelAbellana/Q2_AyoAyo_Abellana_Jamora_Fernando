import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ayoayo/widgets/diagnosis/camera_device_scanner.dart';
import 'package:ayoayo/services/camera_device_recognition_service.dart';
import 'package:ayoayo/providers/device_provider.dart';
import 'package:ayoayo/services/user_service.dart';

class DeviceScannerScreen extends StatefulWidget {
  const DeviceScannerScreen({super.key});

  @override
  State<DeviceScannerScreen> createState() => _DeviceScannerScreenState();
}

class _DeviceScannerScreenState extends State<DeviceScannerScreen> {
  final CameraDeviceRecognitionService _recognitionService = CameraDeviceRecognitionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Scanner'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showScanningTips(context),
            icon: Icon(LucideIcons.helpCircle),
            tooltip: 'Scanning Tips',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroduction(),
              const SizedBox(height: 24),
              CameraDeviceScanner(
                onDeviceRecognized: _handleDeviceRecognized,
                onError: _handleError,
              ),
              const SizedBox(height: 24),
              _buildBenefitsSection(),
              const SizedBox(height: 24),
              _buildSupportedDevices(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                color: Theme.of(context).primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI-Powered Device Recognition',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Simply take photos of your device and let our AI identify the exact model, manufacturer, and specifications. Create a digital passport and get instant insights about value, condition, and sustainable options.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Use Device Scanner?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          _BenefitItem(
            icon: LucideIcons.zap,
            title: 'Instant Recognition',
            description: 'AI identifies your device in seconds with high accuracy',
          ),
          _BenefitItem(
            icon: LucideIcons.database,
            title: 'Auto-Fill Information',
            description: 'Automatically populate device specifications and details',
          ),
          _BenefitItem(
            icon: LucideIcons.dollarSign,
            title: 'Value Assessment',
            description: 'Get instant market value and resale price estimates',
          ),
          _BenefitItem(
            icon: LucideIcons.recycle,
            title: 'Sustainable Options',
            description: 'Discover repair, resell, and upcycling opportunities',
          ),
        ].map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: item,
        )),
      ],
    );
  }

  Widget _buildSupportedDevices() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.smartphone,
                size: 20,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                'Supported Devices',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'iPhone', 'Samsung Galaxy', 'Xiaomi', 'Huawei',
              'OnePlus', 'Google Pixel', 'OPPO', 'Vivo'
            ].map((brand) => Chip(
              label: Text(
                brand,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.white,
              side: BorderSide(color: Colors.grey.shade300),
            )).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'More brands supported with regular updates',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeviceRecognized(DeviceRecognitionResult result) async {
    try {

      final currentUser = await UserService.getCurrentUser();

      if (currentUser == null) {
        _handleError('Please log in to save device information');
        return;
      }

      await _recognitionService.saveRecognizedDevice(
        result,
        currentUser['uid'] ?? currentUser['id'].toString(),
        [], // Image URLs would be populated in a real implementation
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(LucideIcons.check, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Device Saved Successfully!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${result.manufacturer} ${result.deviceModel}'),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'View Devices',
              textColor: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        );

        // Refresh device provider
        final deviceProvider = Provider.of<DeviceProvider>(context, listen: false);
        deviceProvider.loadDevices();
      }
    } catch (e) {
      _handleError('Failed to save device: $e');
    }
  }

  void _handleError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(LucideIcons.alertCircle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(error)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }


  void _showScanningTips(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(LucideIcons.lightbulb, color: Colors.amber),
            SizedBox(width: 12),
            Text('Scanning Tips'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'For best results:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...[
                '• Take clear, well-lit photos',
                '• Capture front, back, and side views',
                '• Include logos and camera modules',
                '• Avoid reflections and shadows',
                '• Show any model numbers or text',
                '• Multiple angles increase accuracy',
              ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(tip),
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}