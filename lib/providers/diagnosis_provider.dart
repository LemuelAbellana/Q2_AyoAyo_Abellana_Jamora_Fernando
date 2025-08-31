import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/models/device_diagnosis.dart';
import '/services/gemini_diagnosis_service.dart';

class DiagnosisProvider extends ChangeNotifier {
  final GeminiDiagnosisService _diagnosisService = GeminiDiagnosisService();

  // Current diagnosis data
  String _deviceModel = '';
  String _additionalInfo = '';
  final List<File> _selectedImages = [];

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

  // Setters
  void setDeviceModel(String model) {
    _deviceModel = model.trim();
    notifyListeners();
  }

  void setAdditionalInfo(String info) {
    _additionalInfo = info.trim();
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

  // Reset all data
  void reset() {
    _deviceModel = '';
    _additionalInfo = '';
    _selectedImages.clear();
    _currentResult = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Get formatted battery health
  String getFormattedBatteryHealth() {
    if (_currentResult?.deviceHealth.batteryHealth != null) {
      return '${_currentResult!.deviceHealth.batteryHealth.toStringAsFixed(0)}%';
    }
    return 'Unknown';
  }

  // Get screen condition display text
  String getScreenConditionText() {
    final condition = _currentResult?.deviceHealth.screenCondition;
    if (condition == null) return 'Unknown';

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
    if (health >= 80) return Colors.green;
    if (health >= 60) return Colors.orange;
    return Colors.red;
  }

  // Get color for screen condition
  Color getScreenConditionColor() {
    final condition = _currentResult?.deviceHealth.screenCondition;
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
      default:
        return Colors.grey;
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
