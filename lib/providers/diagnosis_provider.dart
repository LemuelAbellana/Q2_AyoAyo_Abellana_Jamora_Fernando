import 'dart:io';

import 'package:flutter/material.dart';
import '/models/device_diagnosis.dart';
import '/services/gemini_diagnosis_service.dart';
import '/models/pathway.dart'; // Added import for Pathway

class DiagnosisProvider extends ChangeNotifier {
  final GeminiDiagnosisService _diagnosisService = GeminiDiagnosisService();

  // Current diagnosis data
  String _deviceModel = '';
  String _additionalInfo = '';
  final List<File> _selectedImages = [];

  // Device Passport data
  String _manufacturer = '';
  int _yearOfRelease = DateTime.now().year;
  String _operatingSystem = '';

  // Selected pathway
  Pathway _selectedPathway = Pathway.none; // Added selectedPathway

  // Getters
  Pathway get selectedPathway =>
      _selectedPathway; // Added getter for selectedPathway

  // Results
  DiagnosisResult? _currentResult;
  bool _isLoading = false;
  String? _error;

  // Getters
  String get deviceModel => _deviceModel;
  String get additionalInfo => _additionalInfo;
  List<File> get selectedImages => List.unmodifiable(_selectedImages);
  DiagnosisResult? get currentResult => _currentResult;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasImages => _selectedImages.isNotEmpty;
  bool get canStartDiagnosis => _deviceModel.isNotEmpty;

  // Device Passport getters
  String get manufacturer => _manufacturer;
  int get yearOfRelease => _yearOfRelease;
  String get operatingSystem => _operatingSystem;

  // Setters
  void setDeviceModel(String model) {
    _deviceModel = model.trim();
    notifyListeners();
  }

  void setAdditionalInfo(String info) {
    _additionalInfo = info.trim();
    notifyListeners();
  }

  // Device Passport setters
  void setManufacturer(String manufacturer) {
    _manufacturer = manufacturer.trim();
    notifyListeners();
  }

  void setYearOfRelease(String year) {
    _yearOfRelease = int.tryParse(year) ?? DateTime.now().year;
    notifyListeners();
  }

  void setOperatingSystem(String os) {
    _operatingSystem = os.trim();
    notifyListeners();
  }

  void setSelectedImages(List<File> images) {
    _selectedImages.clear();
    _selectedImages.addAll(images);
    notifyListeners();
  }

  void addImage(File image) {
    if (_selectedImages.length < 3) {
      // Limit to 3 images
      _selectedImages.add(image);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  void clearImages() {
    _selectedImages.clear();
    notifyListeners();
  }

  // Main diagnosis method
  Future<void> startDiagnosis() async {
    if (!canStartDiagnosis) {
      _error = 'Please provide a device model to start diagnosis';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _currentResult = null;
    notifyListeners();

    try {
      final diagnosis = DeviceDiagnosis(
        deviceModel: _deviceModel,
        images: _selectedImages,
        additionalInfo: _additionalInfo.isEmpty ? null : _additionalInfo,
      );

      _currentResult = await _diagnosisService.diagnoseMobileDevice(diagnosis);
      _error = null;
    } catch (e) {
      _error = 'Failed to complete diagnosis: ${e.toString()}';
      _currentResult = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedPathway(Pathway pathway) {
    // Added setter for selectedPathway
    _selectedPathway = pathway;
    notifyListeners();
  }

  // Test screen condition detection
  ScreenCondition testScreenCondition(String input) {
    return _diagnosisService.testScreenConditionDetection(
      _deviceModel,
      input,
      null,
    );
  }

  // Debug current diagnosis result
  String debugCurrentScreenCondition() {
    if (_currentResult == null) return 'No diagnosis result available';

    final condition = _currentResult!.deviceHealth.screenCondition;
    final additionalInfo = _additionalInfo;

    return '''
    Current Screen Condition: ${condition.toString().split('.').last}
    User Input: "${additionalInfo.isEmpty ? 'None' : additionalInfo}"
    Device Model: $_deviceModel
    Images Uploaded: ${selectedImages.length}

    Detection Logic:
    - Contains 'crack': ${additionalInfo.contains('crack')}
    - Contains 'cracked': ${additionalInfo.contains('cracked')}
    - Contains 'cracked lcd': ${additionalInfo.contains('cracked lcd')}
    - Contains 'broken screen': ${additionalInfo.contains('broken screen')}
    - Contains 'screen crack': ${additionalInfo.contains('screen crack')}
    - Contains 'display crack': ${additionalInfo.contains('display crack')}

    AI Analysis Available: ${currentResult!.aiAnalysis.isNotEmpty ? 'Yes' : 'No'}
    Confidence Score: ${currentResult?.confidenceScore ?? 'N/A'}
    ''';
  }

  // Force test screen condition detection
  Future<String> testScreenConditionWithCurrentData() async {
    try {
      final diagnosis = DeviceDiagnosis(
        deviceModel: _deviceModel,
        images: _selectedImages,
        additionalInfo: _additionalInfo.isEmpty ? null : _additionalInfo,
      );

      final testResult = await _diagnosisService.diagnoseMobileDevice(
        diagnosis,
      );

      return '''
      TEST RESULT:
      Screen Condition: ${testResult.deviceHealth.screenCondition.toString().split('.').last}
      Battery Health: ${testResult.deviceHealth.batteryHealth.toStringAsFixed(0)}%
      Hardware Condition: ${testResult.deviceHealth.hardwareCondition.toString().split('.').last}

      Values:
      - Current: ₱${testResult.valueEstimation.currentValue.toStringAsFixed(0)}
      - Post-Repair: ₱${testResult.valueEstimation.postRepairValue.toStringAsFixed(0)}
      - Parts: ₱${testResult.valueEstimation.partsValue.toStringAsFixed(0)}
      - Repair Cost: ₱${testResult.valueEstimation.repairCost.toStringAsFixed(0)}

      Confidence: ${testResult.confidenceScore.toStringAsFixed(2)}
      ''';
    } catch (e) {
      return 'Test failed: $e';
    }
  }

  // Reset all data
  void reset() {
    _deviceModel = '';
    _additionalInfo = '';
    _selectedImages.clear();
    _currentResult = null;
    _error = null;
    _isLoading = false;
    _selectedPathway = Pathway.none; // Reset selected pathway on reset

    // Reset device passport data
    _manufacturer = '';
    _yearOfRelease = DateTime.now().year;
    _operatingSystem = '';

    notifyListeners();
  }

  // Get formatted battery health
  String getFormattedBatteryHealth() {
    if (_currentResult?.deviceHealth.batteryHealth != null) {
      final health = _currentResult!.deviceHealth.batteryHealth;
      if (health > 0) {
        return '${health.toStringAsFixed(0)}%';
      }
    }
    return 'Unknown';
  }

  // Get screen condition display text
  String getScreenConditionText() {
    // If no diagnosis has been run yet, show placeholder
    if (_currentResult == null) {
      return 'Pending Diagnosis';
    }

    // If diagnosis is in progress, show assessing
    if (_isLoading) {
      return 'Analyzing...';
    }

    final condition = _currentResult!.deviceHealth.screenCondition;

    // With our safeguards, condition should never be null, but we handle it just in case
    return _screenConditionToString(condition);
  }

  // Helper method to convert ScreenCondition to display string
  String _screenConditionToString(ScreenCondition condition) {
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
        // This should never happen with our intelligent defaults
        print('⚠️ Screen condition is unknown - using fallback');
        return 'Good'; // Safe fallback
    }
  }

  // Get hardware condition display text
  String getHardwareConditionText() {
    final condition = _currentResult?.deviceHealth.hardwareCondition;
    if (condition == null) return 'Unknown';

    switch (condition) {
      case HardwareCondition.excellent:
        return 'Excellent';
      case HardwareCondition.good:
        return 'Good';
      case HardwareCondition.fair:
        return 'Fair';
      case HardwareCondition.poor:
        return 'Poor';
      case HardwareCondition.damaged:
        return 'Damaged';
      case HardwareCondition.unknown:
        return 'Unknown';
    }
  }

  // Get formatted current value
  String getFormattedCurrentValue() {
    final value = _currentResult?.valueEstimation.currentValue;
    final currency = _currentResult?.valueEstimation.currency ?? '₱';
    if (value != null) {
      return '$currency${value.toStringAsFixed(0)}';
    }
    return 'Unknown';
  }

  // Get formatted post-repair value
  String getFormattedPostRepairValue() {
    final value = _currentResult?.valueEstimation.postRepairValue;
    final currency = _currentResult?.valueEstimation.currency ?? '₱';
    if (value != null) {
      return '$currency${value.toStringAsFixed(0)}';
    }
    return 'Unknown';
  }

  // Get formatted parts value
  String getFormattedPartsValue() {
    final value = _currentResult?.valueEstimation.partsValue;
    final currency = _currentResult?.valueEstimation.currency ?? '₱';
    if (value != null) {
      return '$currency${value.toStringAsFixed(0)}';
    }
    return 'Unknown';
  }

  // Get color for battery health
  Color getBatteryHealthColor() {
    final health = _currentResult?.deviceHealth.batteryHealth ?? 0;
    if (health == 0) return Colors.grey; // Unknown/undetermined
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.orange;
    return Colors.red;
  }

  // Get color for screen condition
  Color getScreenConditionColor() {
    // If no diagnosis has been run yet
    if (_currentResult == null) {
      return Colors.grey; // Grey for "pending diagnosis"
    }

    // If diagnosis is in progress
    if (_isLoading) {
      return Colors.blue; // Blue for "analyzing"
    }

    final condition = _currentResult!.deviceHealth.screenCondition;

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
        // This should never happen with our intelligent defaults
        print('⚠️ Screen condition is unknown - this should not happen');
        return Colors.green; // Default to green for unknown cases
    }
  }

  // Get sorted recommendations by priority
  List<RecommendedAction> getSortedRecommendations() {
    if (_currentResult?.recommendations == null) return [];

    final recommendations = List<RecommendedAction>.from(
      _currentResult!.recommendations,
    );
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    return recommendations;
  }
}
