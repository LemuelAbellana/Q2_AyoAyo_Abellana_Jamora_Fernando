import 'package:flutter/foundation.dart';
import '../models/device_passport.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../config/api_config.dart';

class DeviceProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<DevicePassport> _devices = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<DevicePassport> get devices => List.unmodifiable(_devices);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasDevices => _devices.isNotEmpty;

  // Load devices from database or backend
  Future<void> loadDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try backend first if enabled and authenticated
      if (ApiConfig.useBackendApi && ApiService.isAuthenticated) {
        try {
          await _loadDevicesFromBackend();
          return;
        } catch (e) {
          debugPrint('⚠️ Backend load failed, falling back to local: $e');
        }
      }

      // Local storage fallback using SharedPreferences
      await _loadDevicesLocal();
    } catch (e) {
      _error = 'Failed to load devices: ${e.toString()}';
      debugPrint('❌ Error loading devices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load devices from backend API
  Future<void> _loadDevicesFromBackend() async {
    debugPrint('📡 Loading devices from backend');

    final currentUser = await UserService.getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not authenticated');
    }

    final userId = currentUser['uid'] ?? currentUser['id'].toString();
    final devicesData = await ApiService.getDevicePassports(userId);

    _devices = devicesData
        .map((data) => DevicePassport.fromJson(data as Map<String, dynamic>))
        .toList();

    debugPrint('✅ Loaded ${_devices.length} devices from backend');
  }

  Future<void> _loadDevicesLocal() async {
    try {
      final devicesData = await _databaseService.getWebDevicePassports();
      _devices = devicesData.map((data) => DevicePassport.fromJson(data)).toList();
    } catch (e) {
      debugPrint('Error loading local devices: $e');
      _devices = [];
    }
  }

  // Add a new device passport
  Future<void> addDevice(DevicePassport passport) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _addDeviceLocal(passport);
      _devices.insert(0, passport);
      _error = null;
    } catch (e) {
      _error = 'Failed to add device: ${e.toString()}';
      debugPrint('Error adding device: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _addDeviceLocal(DevicePassport passport) async {
    final devices = await _databaseService.getWebDevicePassports();
    devices.add(passport.toJson());
    await _databaseService.saveWebDevicePassports(devices);
  }

  // Remove a device
  Future<void> removeDevice(String deviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _removeDeviceLocal(deviceId);
      _devices.removeWhere((device) => device.id == deviceId);
    } catch (e) {
      _error = 'Failed to remove device: ${e.toString()}';
      debugPrint('Error removing device: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _removeDeviceLocal(String deviceId) async {
    final devices = await _databaseService.getWebDevicePassports();
    devices.removeWhere((deviceData) => deviceData['id'] == deviceId);
    await _databaseService.saveWebDevicePassports(devices);
  }

  // Get device by ID
  DevicePassport? getDeviceById(String deviceId) {
    try {
      return _devices.firstWhere((device) => device.id == deviceId);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh devices
  Future<void> refresh() async {
    await loadDevices();
  }
}
