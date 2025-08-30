import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class DeviceDiagnosis {
  final String deviceModel;
  final List<File> images;
  final List<Uint8List>? imageBytes; // For web compatibility
  final String? additionalInfo;
  final DateTime timestamp;

  DeviceDiagnosis({
    required this.deviceModel,
    required this.images,
    this.imageBytes,
    this.additionalInfo,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'deviceModel': deviceModel,
      'additionalInfo': additionalInfo,
      'timestamp': timestamp.toIso8601String(),
      'imageCount': images.length,
    };
  }
}

class DiagnosisResult {
  final String deviceModel;
  final DeviceHealth deviceHealth;
  final ValueEstimation valueEstimation;
  final List<RecommendedAction> recommendations;
  final String aiAnalysis;
  final double confidenceScore;

  DiagnosisResult({
    required this.deviceModel,
    required this.deviceHealth,
    required this.valueEstimation,
    required this.recommendations,
    required this.aiAnalysis,
    required this.confidenceScore,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      deviceModel: json['deviceModel'] ?? '',
      deviceHealth: DeviceHealth.fromJson(json['deviceHealth'] ?? {}),
      valueEstimation: ValueEstimation.fromJson(json['valueEstimation'] ?? {}),
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => RecommendedAction.fromJson(e))
              .toList() ??
          [],
      aiAnalysis: json['aiAnalysis'] ?? '',
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceModel': deviceModel,
      'deviceHealth': deviceHealth.toJson(),
      'valueEstimation': valueEstimation.toJson(),
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
      'aiAnalysis': aiAnalysis,
      'confidenceScore': confidenceScore,
    };
  }
}

class DeviceHealth {
  final double batteryHealth;
  final ScreenCondition screenCondition;
  final HardwareCondition hardwareCondition;
  final List<String> identifiedIssues;

  DeviceHealth({
    required this.batteryHealth,
    required this.screenCondition,
    required this.hardwareCondition,
    required this.identifiedIssues,
  });

  factory DeviceHealth.fromJson(Map<String, dynamic> json) {
    return DeviceHealth(
      batteryHealth: (json['batteryHealth'] ?? 0.0).toDouble(),
      screenCondition: ScreenCondition.values.firstWhere(
        (e) => e.name == json['screenCondition'],
        orElse: () => ScreenCondition.unknown,
      ),
      hardwareCondition: HardwareCondition.values.firstWhere(
        (e) => e.name == json['hardwareCondition'],
        orElse: () => HardwareCondition.unknown,
      ),
      identifiedIssues: List<String>.from(json['identifiedIssues'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batteryHealth': batteryHealth,
      'screenCondition': screenCondition.name,
      'hardwareCondition': hardwareCondition.name,
      'identifiedIssues': identifiedIssues,
    };
  }
}

class ValueEstimation {
  final double currentValue;
  final double postRepairValue;
  final double partsValue;
  final double repairCost;
  final String currency;

  ValueEstimation({
    required this.currentValue,
    required this.postRepairValue,
    required this.partsValue,
    required this.repairCost,
    this.currency = '₱',
  });

  factory ValueEstimation.fromJson(Map<String, dynamic> json) {
    return ValueEstimation(
      currentValue: (json['currentValue'] ?? 0.0).toDouble(),
      postRepairValue: (json['postRepairValue'] ?? 0.0).toDouble(),
      partsValue: (json['partsValue'] ?? 0.0).toDouble(),
      repairCost: (json['repairCost'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? '₱',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentValue': currentValue,
      'postRepairValue': postRepairValue,
      'partsValue': partsValue,
      'repairCost': repairCost,
      'currency': currency,
    };
  }
}

class RecommendedAction {
  final String title;
  final String description;
  final ActionType type;
  final double priority;

  RecommendedAction({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
  });

  factory RecommendedAction.fromJson(Map<String, dynamic> json) {
    return RecommendedAction(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ActionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActionType.other,
      ),
      priority: (json['priority'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'priority': priority,
    };
  }
}

enum ScreenCondition { excellent, good, fair, poor, cracked, unknown }

enum HardwareCondition { excellent, good, fair, poor, damaged, unknown }

enum ActionType { repair, replace, donate, recycle, sell, other }
