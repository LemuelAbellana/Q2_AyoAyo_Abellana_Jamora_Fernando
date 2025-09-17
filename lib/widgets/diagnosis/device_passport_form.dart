import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:ayoayo/widgets/diagnosis/image_upload_placeholder.dart';

class DevicePassportForm extends StatefulWidget {
  final Function(String, String, int, List<File>) onSubmit;

  const DevicePassportForm({super.key, required this.onSubmit});

  @override
  State<DevicePassportForm> createState() => DevicePassportFormState();
}

class DevicePassportFormState extends State<DevicePassportForm> {
  final _formKey = GlobalKey<FormState>();
  final _deviceModelController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _yearOfReleaseController = TextEditingController();
  List<File> _imagePaths = [];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.smartphone,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Device Information',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tell us about your device to create its digital passport',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Device Details Section
          Text(
            'Device Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Device Model Field
          Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _deviceModelController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Device Model',
                  hintText: 'e.g., iPhone 13 Pro, Galaxy S21',
                  prefixIcon: Icon(
                    LucideIcons.smartphone,
                    color: Theme.of(context).primaryColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a device model';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Manufacturer Field
          Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _manufacturerController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Manufacturer',
                  hintText: 'e.g., Apple, Samsung, Google',
                  prefixIcon: Icon(
                    LucideIcons.building,
                    color: Theme.of(context).primaryColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a manufacturer';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Year of Release Field
          Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _yearOfReleaseController,
                style: const TextStyle(fontSize: 16),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Year of Release',
                  hintText: 'e.g., 2021',
                  prefixIcon: Icon(
                    LucideIcons.calendar,
                    color: Theme.of(context).primaryColor,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a year of release';
                  }
                  final year = int.tryParse(value);
                  if (year == null) {
                    return 'Please enter a valid year';
                  }
                  if (year < 2000 || year > DateTime.now().year + 1) {
                    return 'Please enter a valid year between 2000 and ${DateTime.now().year + 1}';
                  }
                  return null;
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Images Section
          Row(
            children: [
              Icon(
                LucideIcons.camera,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Device Images',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Upload clear photos of your device from different angles for accurate diagnosis',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          ImageUploadPlaceholder(
            label: 'Tap to add device photos',
            onImagesSelected: (imagePaths) {
              setState(() {
                _imagePaths = imagePaths;
              });
            },
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _imagePaths.isEmpty
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSubmit(
                          _deviceModelController.text.trim(),
                          _manufacturerController.text.trim(),
                          int.parse(_yearOfReleaseController.text),
                          _imagePaths,
                        );
                      }
                    },
              icon: const Icon(LucideIcons.sparkles, size: 20),
              label: const Text(
                'Create Device Passport',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          if (_imagePaths.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Please add at least one device image to continue',
                style: TextStyle(color: Colors.orange[700], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
