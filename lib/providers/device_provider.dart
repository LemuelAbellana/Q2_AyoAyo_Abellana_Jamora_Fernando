import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/device_passport.dart';
import '../models/device_diagnosis.dart';
import '../services/database_service.dart';

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

  // Load devices from database
  Future<void> loadDevices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        await _loadDevicesWeb();
      } else {
        await _loadDevicesSQLite();
      }
    } catch (e) {
      _error = 'Failed to load devices: ${e.toString()}';
      debugPrint('Error loading devices: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDevicesWeb() async {
    try {
      // For web, we'll store devices using a similar pattern to other data
      final devicesData = await _databaseService.getWebDevicePassports();
      _devices = devicesData.map((data) => DevicePassport.fromJson(data)).toList();
    } catch (e) {
      // Fallback to empty list if there's an issue
      _devices = [];
    }
  }

  Future<void> _loadDevicesSQLite() async {
    try {
      final db = await _databaseService.database as Database;

      // Query devices with their latest diagnosis and value estimation
      final result = await db.rawQuery('''
        SELECT
          dp.passport_uuid as id,
          dp.user_id,
          d.device_model,
          d.manufacturer,
          d.year_of_release,
          d.operating_system,
          GROUP_CONCAT(di.image_path) as image_urls,
          diag.ai_analysis,
          diag.confidence_score,
          diag.battery_health,
          diag.screen_condition,
          diag.hardware_condition,
          diag.identified_issues,
          diag.life_cycle_stage,
          diag.remaining_useful_life,
          diag.environmental_impact,
          ve.current_value,
          ve.post_repair_value,
          ve.parts_value,
          ve.repair_cost,
          ve.recycling_value,
          ve.currency,
          ve.market_positioning,
          ve.depreciation_rate
        FROM device_passports dp
        LEFT JOIN devices d ON dp.device_id = d.id
        LEFT JOIN device_images di ON d.id = di.device_id
        LEFT JOIN diagnoses diag ON dp.last_diagnosis_id = diag.id
        LEFT JOIN value_estimations ve ON diag.id = ve.diagnosis_id
        WHERE dp.is_active = 1
        GROUP BY dp.id
        ORDER BY dp.created_at DESC
      ''');

      _devices = result.map((row) => _mapToDevicePassport(row)).toList();
    } catch (e) {
      debugPrint('Error loading SQLite devices: $e');
      _devices = [];
    }
  }

  DevicePassport _mapToDevicePassport(Map<String, dynamic> row) {
    try {
      // Handle image URLs
      final imageUrlsString = row['image_urls'] as String?;
      final imageUrls = imageUrlsString?.split(',').where((url) => url.trim().isNotEmpty).toList() ?? [];

      // Handle identified issues
      final identifiedIssuesString = row['identified_issues'] as String?;
      final identifiedIssues = identifiedIssuesString?.split(',').where((issue) => issue.trim().isNotEmpty).toList() ?? [];

      // Create diagnosis result with fallback values
      final diagnosisResult = DiagnosisResult(
        deviceModel: row['device_model']?.toString() ?? 'Unknown Device',
        imageUrls: imageUrls,
        aiAnalysis: row['ai_analysis']?.toString() ?? 'No analysis available',
        confidenceScore: (row['confidence_score'] as num?)?.toDouble() ?? 0.8,
        deviceHealth: DeviceHealth(
          screenCondition: _parseScreenCondition(row['screen_condition']?.toString()),
          hardwareCondition: _parseHardwareCondition(row['hardware_condition']?.toString()),
          identifiedIssues: identifiedIssues,
          lifeCycleStage: row['life_cycle_stage']?.toString() ?? 'Active',
          remainingUsefulLife: row['remaining_useful_life']?.toString() ?? '2-3 years',
          environmentalImpact: row['environmental_impact']?.toString() ?? 'Low carbon footprint',
        ),
        valueEstimation: ValueEstimation(
          currentValue: (row['current_value'] as num?)?.toDouble() ?? 5000.0,
          postRepairValue: (row['post_repair_value'] as num?)?.toDouble() ?? 6000.0,
          partsValue: (row['parts_value'] as num?)?.toDouble() ?? 2000.0,
          repairCost: (row['repair_cost'] as num?)?.toDouble() ?? 1000.0,
          recyclingValue: (row['recycling_value'] as num?)?.toDouble() ?? 500.0,
          currency: row['currency']?.toString() ?? 'PHP',
          marketPositioning: row['market_positioning']?.toString() ?? 'Mid-range',
          depreciationRate: row['depreciation_rate']?.toString() ?? '15% per year',
        ),
        recommendations: [], // Would need separate query for recommendations
      );

      return DevicePassport(
        id: row['id']?.toString() ?? 'unknown_${DateTime.now().millisecondsSinceEpoch}',
        userId: row['user_id']?.toString() ?? 'user_1',
        deviceModel: row['device_model']?.toString() ?? 'Unknown Device',
        manufacturer: row['manufacturer']?.toString() ?? 'Unknown',
        yearOfRelease: (row['year_of_release'] as int?) ?? DateTime.now().year,
        operatingSystem: row['operating_system']?.toString() ?? 'Unknown',
        imageUrls: imageUrls,
        lastDiagnosis: diagnosisResult,
      );
    } catch (e) {
      debugPrint('Error mapping device passport: $e');
      // Return a fallback device passport
      return DevicePassport(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_1',
        deviceModel: 'Unknown Device',
        manufacturer: 'Unknown',
        yearOfRelease: DateTime.now().year,
        operatingSystem: 'Unknown',
        imageUrls: [],
        lastDiagnosis: DiagnosisResult(
          deviceModel: 'Unknown Device',
          imageUrls: [],
          aiAnalysis: 'Error loading device data',
          confidenceScore: 0.0,
          deviceHealth: DeviceHealth(
            screenCondition: ScreenCondition.unknown,
            hardwareCondition: HardwareCondition.unknown,
            identifiedIssues: [],
            lifeCycleStage: '',
            remainingUsefulLife: '',
            environmentalImpact: '',
          ),
          valueEstimation: ValueEstimation(
            currentValue: 0.0,
            postRepairValue: 0.0,
            partsValue: 0.0,
            repairCost: 0.0,
            recyclingValue: 0.0,
            currency: 'PHP',
            marketPositioning: '',
            depreciationRate: '',
          ),
          recommendations: [],
        ),
      );
    }
  }

  ScreenCondition _parseScreenCondition(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'excellent':
        return ScreenCondition.excellent;
      case 'good':
        return ScreenCondition.good;
      case 'fair':
        return ScreenCondition.fair;
      case 'poor':
        return ScreenCondition.poor;
      case 'cracked':
        return ScreenCondition.cracked;
      default:
        return ScreenCondition.unknown;
    }
  }

  HardwareCondition _parseHardwareCondition(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'excellent':
        return HardwareCondition.excellent;
      case 'good':
        return HardwareCondition.good;
      case 'fair':
        return HardwareCondition.fair;
      case 'poor':
        return HardwareCondition.poor;
      case 'damaged':
        return HardwareCondition.damaged;
      default:
        return HardwareCondition.unknown;
    }
  }

  // Add a new device passport
  Future<void> addDevice(DevicePassport passport) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        await _addDeviceWeb(passport);
      } else {
        await _addDeviceSQLite(passport);
      }

      // Add device to local list immediately to avoid reload
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

  Future<void> _addDeviceWeb(DevicePassport passport) async {
    final devices = await _databaseService.getWebDevicePassports();
    devices.add(passport.toJson());
    await _databaseService.saveWebDevicePassports(devices);
  }

  Future<void> _addDeviceSQLite(DevicePassport passport) async {
    final db = await _databaseService.database as Database;

    await db.transaction((txn) async {
      // Insert device
      final deviceId = await txn.insert('devices', {
        'device_model': passport.deviceModel,
        'manufacturer': passport.manufacturer,
        'year_of_release': passport.yearOfRelease,
        'operating_system': passport.operatingSystem,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Insert diagnosis
      final diagnosisId = await txn.insert('diagnoses', {
        'user_id': 1, // TODO: Get from auth service
        'device_id': deviceId,
        'diagnosis_uuid': 'diag_${DateTime.now().millisecondsSinceEpoch}',
        'screen_condition': passport.lastDiagnosis.deviceHealth.screenCondition.name,
        'hardware_condition': passport.lastDiagnosis.deviceHealth.hardwareCondition.name,
        'identified_issues': passport.lastDiagnosis.deviceHealth.identifiedIssues.join(','),
        'ai_analysis': passport.lastDiagnosis.aiAnalysis,
        'confidence_score': passport.lastDiagnosis.confidenceScore,
        'life_cycle_stage': passport.lastDiagnosis.deviceHealth.lifeCycleStage,
        'remaining_useful_life': passport.lastDiagnosis.deviceHealth.remainingUsefulLife,
        'environmental_impact': passport.lastDiagnosis.deviceHealth.environmentalImpact,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Insert value estimation
      await txn.insert('value_estimations', {
        'diagnosis_id': diagnosisId,
        'current_value': passport.lastDiagnosis.valueEstimation.currentValue,
        'post_repair_value': passport.lastDiagnosis.valueEstimation.postRepairValue,
        'parts_value': passport.lastDiagnosis.valueEstimation.partsValue,
        'repair_cost': passport.lastDiagnosis.valueEstimation.repairCost,
        'recycling_value': passport.lastDiagnosis.valueEstimation.recyclingValue,
        'currency': passport.lastDiagnosis.valueEstimation.currency,
        'market_positioning': passport.lastDiagnosis.valueEstimation.marketPositioning,
        'depreciation_rate': passport.lastDiagnosis.valueEstimation.depreciationRate,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Insert device images
      for (final imageUrl in passport.imageUrls) {
        await txn.insert('device_images', {
          'device_id': deviceId,
          'image_path': imageUrl,
          'image_type': 'diagnostic',
          'uploaded_by': 1, // TODO: Get from auth service
          'uploaded_at': DateTime.now().toIso8601String(),
        });
      }

      // Insert device passport
      await txn.insert('device_passports', {
        'user_id': 1, // TODO: Get from auth service
        'device_id': deviceId,
        'passport_uuid': passport.id,
        'last_diagnosis_id': diagnosisId,
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    });
  }

  // Remove a device
  Future<void> removeDevice(String deviceId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        await _removeDeviceWeb(deviceId);
      } else {
        await _removeDeviceSQLite(deviceId);
      }

      // Remove from local list
      _devices.removeWhere((device) => device.id == deviceId);
    } catch (e) {
      _error = 'Failed to remove device: ${e.toString()}';
      debugPrint('Error removing device: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _removeDeviceWeb(String deviceId) async {
    final devices = await _databaseService.getWebDevicePassports();
    devices.removeWhere((deviceData) => deviceData['id'] == deviceId);
    await _databaseService.saveWebDevicePassports(devices);
  }

  Future<void> _removeDeviceSQLite(String deviceId) async {
    final db = await _databaseService.database as Database;

    await db.update(
      'device_passports',
      {'is_active': 0},
      where: 'passport_uuid = ?',
      whereArgs: [deviceId],
    );
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