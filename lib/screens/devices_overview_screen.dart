import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/device_provider.dart';
import '../models/device_passport.dart';
import 'device_passport_form_screen.dart';
import 'device_scanner_screen.dart';
import '../widgets/devices/glassmorphic_device_card.dart';
import '../utils/app_theme.dart';

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
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundLight,
              Colors.blue.shade50.withValues(alpha: 0.3),
              Colors.cyan.shade50.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: Consumer<DeviceProvider>(
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
          return GlassmorphicDeviceCard(
            device: device,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Device details for ${device.deviceModel} coming soon!',
                  ),
                ),
              );
            },
            onDelete: () => _showDeleteConfirmation(context, device),
          );
        },
      ),
    );
  }

  // Removed _getConditionColor and _getConditionText - now handled by glassmorphic component

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
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                child: const Icon(LucideIcons.pencil, color: Colors.grey),
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
