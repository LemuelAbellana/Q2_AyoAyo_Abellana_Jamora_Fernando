import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../models/device_passport.dart';
import '../models/device_diagnosis.dart';
import 'device_passport_form_screen.dart';
import 'device_scanner_screen.dart';

class DevicesOverviewScreen extends StatefulWidget {
  const DevicesOverviewScreen({super.key});

  @override
  State<DevicesOverviewScreen> createState() => _DevicesOverviewScreenState();
}

class _DevicesOverviewScreenState extends State<DevicesOverviewScreen> {
  @override
  void initState() {
    super.initState();
    // Load devices when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Devices')),
      body: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          if (deviceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (deviceProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.x, size: 48, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading devices',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deviceProvider.error!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => deviceProvider.refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return !deviceProvider.hasDevices
              ? _buildEmptyState(context)
              : _buildDevicesList(context, deviceProvider.devices);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceOptions(context),
        tooltip: 'Add Device',
        label: const Text('Add Device'),
        icon: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            onPressed: () => _navigateToAddDevice(context),
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add Device'),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(BuildContext context, List<DevicePassport> devices) {
    return RefreshIndicator(
      onRefresh: () => context.read<DeviceProvider>().refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  LucideIcons.smartphone,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
              ),
              title: Text(
                device.deviceModel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.cpu, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        device.manufacturer,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.heart,
                        size: 14,
                        color: _getConditionColor(
                          device.lastDiagnosis.deviceHealth.screenCondition,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getConditionText(
                          device.lastDiagnosis.deviceHealth.screenCondition,
                        ),
                        style: TextStyle(
                          color: _getConditionColor(
                            device.lastDiagnosis.deviceHealth.screenCondition,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        LucideIcons.dollarSign,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${device.lastDiagnosis.valueEstimation.currency}${device.estimatedValue.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                icon: Icon(LucideIcons.chevronDown, color: Colors.grey[400]),
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(context, device);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Remove Device'),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                // Navigate to device details
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Device details for ${device.deviceModel} coming soon!',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getConditionColor(ScreenCondition condition) {
    switch (condition) {
      case ScreenCondition.excellent:
      case ScreenCondition.good:
        return Colors.green;
      case ScreenCondition.fair:
        return Colors.orange;
      case ScreenCondition.poor:
      case ScreenCondition.cracked:
        return Colors.red;
      case ScreenCondition.unknown:
        return Colors.grey;
    }
  }

  String _getConditionText(ScreenCondition condition) {
    switch (condition) {
      case ScreenCondition.excellent:
        return 'Excellent';
      case ScreenCondition.good:
        return 'Good';
      case ScreenCondition.fair:
        return 'Fair';
      case ScreenCondition.poor:
        return 'Poor';
      case ScreenCondition.cracked:
        return 'Cracked';
      case ScreenCondition.unknown:
        return 'Unknown';
    }
  }

  void _showAddDeviceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Device',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.scanLine,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: const Text('Camera Scanner'),
              subtitle: const Text('AI-powered device recognition'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () {
                Navigator.pop(context);
                _navigateToScanner(context);
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.pencil,
                  color: Colors.grey,
                ),
              ),
              title: const Text('Manual Entry'),
              subtitle: const Text('Fill out device details manually'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddDevice(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _navigateToScanner(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DeviceScannerScreen()),
    );

    // If a device was added, refresh the list
    if (result == true && mounted) {
      context.read<DeviceProvider>().refresh();
    }
  }

  void _navigateToAddDevice(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DevicePassportFormScreen()),
    );

    // If a device was added, refresh the list
    if (result == true && mounted) {
      context.read<DeviceProvider>().refresh();
    }
  }

  void _showDeleteConfirmation(BuildContext context, DevicePassport device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Device'),
        content: Text(
          'Are you sure you want to remove ${device.deviceModel}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<DeviceProvider>().removeDevice(device.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${device.deviceModel} removed'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        // Add back to database
                        context.read<DeviceProvider>().addDevice(device);
                      },
                    ),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
