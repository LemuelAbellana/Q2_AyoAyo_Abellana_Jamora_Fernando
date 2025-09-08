import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'device_passport_form_screen.dart';

class DevicesOverviewScreen extends StatefulWidget {
  const DevicesOverviewScreen({super.key});

  @override
  State<DevicesOverviewScreen> createState() => _DevicesOverviewScreenState();
}

class _DevicesOverviewScreenState extends State<DevicesOverviewScreen> {
  // Mock data for demonstration - in real app this would come from provider
  final List<Map<String, dynamic>> _devices = [
    {
      'id': '1',
      'model': 'iPhone 14 Pro',
      'condition': 'Excellent',
      'lastDiagnosis': '2024-01-15',
      'imageUrl': null,
    },
    {
      'id': '2',
      'model': 'Samsung Galaxy S23',
      'condition': 'Good',
      'lastDiagnosis': '2024-01-10',
      'imageUrl': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _devices.isEmpty ? _buildEmptyState() : _buildDevicesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.smartphone, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No devices yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first device to get started',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DevicePassportFormScreen(),
                ),
              );
            },
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add Device'),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Icon(
                LucideIcons.smartphone,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              device['model'],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Condition: ${device['condition']}'),
                Text(
                  'Last diagnosis: ${device['lastDiagnosis']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: Icon(LucideIcons.chevronRight, color: Colors.grey[400]),
            onTap: () {
              // Navigate to device details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Device details for ${device['model']} coming soon!',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
