import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../services/device_specifications_service.dart';
import '../utils/enum_helpers.dart';

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
  final DeviceSpecification? deviceSpecifications;
  final DeviceHealth deviceHealth;
  final ValueEstimation valueEstimation;
  final List<RecommendedAction> recommendations;
  final String aiAnalysis;
  final double confidenceScore;
  final List<String> imageUrls; // Added imageUrls

  DiagnosisResult({
    required this.deviceModel,
    this.deviceSpecifications,
    required this.deviceHealth,
    required this.valueEstimation,
    required this.recommendations,
    required this.aiAnalysis,
    required this.confidenceScore,
    this.imageUrls = const [], // Initialize with empty list
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      deviceModel: json['deviceModel'] ?? '',
      deviceSpecifications: json['deviceSpecifications'] != null
          ? DeviceSpecification.fromJson(json['deviceSpecifications'])
          : null,
      deviceHealth: DeviceHealth.fromJson(json['deviceHealth'] ?? {}),
      valueEstimation: ValueEstimation.fromJson(json['valueEstimation'] ?? {}),
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => RecommendedAction.fromJson(e))
              .toList() ??
          [],
      aiAnalysis: json['aiAnalysis'] ?? '',
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceModel': deviceModel,
      'deviceSpecifications': deviceSpecifications?.toJson(),
      'deviceHealth': deviceHealth.toJson(),
      'valueEstimation': valueEstimation.toJson(),
      'recommendations': recommendations.map((e) => e.toJson()).toList(),
      'aiAnalysis': aiAnalysis,
      'confidenceScore': confidenceScore,
      'imageUrls': imageUrls,
    };
  }
}

class DeviceHealth {
  final ScreenCondition screenCondition;
  final HardwareCondition hardwareCondition;
  final List<String> identifiedIssues;
  final String lifeCycleStage;
  final String remainingUsefulLife;
  final String environmentalImpact;

  DeviceHealth({
    required this.screenCondition,
    required this.hardwareCondition,
    required this.identifiedIssues,
    this.lifeCycleStage = 'unknown',
    this.remainingUsefulLife = 'unknown',
    this.environmentalImpact = 'unknown',
  });

  factory DeviceHealth.fromJson(Map<String, dynamic> json) {
    return DeviceHealth(
      screenCondition: _parseScreenCondition(json['screenCondition']),
      hardwareCondition: _parseHardwareCondition(json['hardwareCondition']),
      identifiedIssues: List<String>.from(json['identifiedIssues'] ?? []),
      lifeCycleStage: json['lifeCycleStage'] ?? 'unknown',
      remainingUsefulLife: json['remainingUsefulLife'] ?? 'unknown',
      environmentalImpact: json['environmentalImpact'] ?? 'unknown',
    );
  }

  static ScreenCondition _parseScreenCondition(dynamic value) {
    if (value == null) return ScreenCondition.unknown;
    final valueStr = value.toString().toLowerCase();

    for (final condition in ScreenCondition.values) {
      if (getEnumName(condition).toLowerCase() == valueStr) {
        return condition;
      }
    }
    return ScreenCondition.unknown;
  }

  static HardwareCondition _parseHardwareCondition(dynamic value) {
    if (value == null) return HardwareCondition.unknown;
    final valueStr = value.toString().toLowerCase();

    for (final condition in HardwareCondition.values) {
      if (getEnumName(condition).toLowerCase() == valueStr) {
        return condition;
      }
    }
    return HardwareCondition.unknown;
  }

  Map<String, dynamic> toJson() {
    return {
      'screenCondition': getEnumName(screenCondition),
      'hardwareCondition': getEnumName(hardwareCondition),
      'identifiedIssues': identifiedIssues,
      'lifeCycleStage': lifeCycleStage,
      'remainingUsefulLife': remainingUsefulLife,
      'environmentalImpact': environmentalImpact,
    };
  }
}

class ValueEstimation {
  final double currentValue;
  final double postRepairValue;
  final double partsValue;
  final double repairCost;
  final double recyclingValue;
  final String currency;
  final String marketPositioning;
  final String depreciationRate;

  ValueEstimation({
    required this.currentValue,
    required this.postRepairValue,
    required this.partsValue,
    required this.repairCost,
    this.recyclingValue = 0.0,
    this.currency = '₱',
    this.marketPositioning = 'unknown',
    this.depreciationRate = 'unknown',
  });

  factory ValueEstimation.fromJson(Map<String, dynamic> json) {
    return ValueEstimation(
      currentValue: (json['currentValue'] ?? 0.0).toDouble(),
      postRepairValue: (json['postRepairValue'] ?? 0.0).toDouble(),
      partsValue: (json['partsValue'] ?? 0.0).toDouble(),
      repairCost: (json['repairCost'] ?? 0.0).toDouble(),
      recyclingValue: (json['recyclingValue'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? '₱',
      marketPositioning: json['marketPositioning'] ?? 'unknown',
      depreciationRate: json['depreciationRate'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentValue': currentValue,
      'postRepairValue': postRepairValue,
      'partsValue': partsValue,
      'repairCost': repairCost,
      'recyclingValue': recyclingValue,
      'currency': currency,
      'marketPositioning': marketPositioning,
      'depreciationRate': depreciationRate,
    };
  }
}

class RecommendedAction {
  final String title;
  final String description;
  final ActionType type;
  final double priority;
  final double costBenefitRatio;
  final String environmentalImpact;
  final String timeframe;
  final double estimatedReturn;
  final String marketTiming;
  final double partsValue;
  final String sustainabilityBenefit;

  RecommendedAction({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    this.costBenefitRatio = 0.0,
    this.environmentalImpact = 'neutral',
    this.timeframe = 'unknown',
    this.estimatedReturn = 0.0,
    this.marketTiming = 'neutral',
    this.partsValue = 0.0,
    this.sustainabilityBenefit = 'neutral',
  });

  factory RecommendedAction.fromJson(Map<String, dynamic> json) {
    return RecommendedAction(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: _parseActionType(json['type']),
      priority: (json['priority'] ?? 0.0).toDouble(),
      costBenefitRatio: (json['costBenefitRatio'] ?? 0.0).toDouble(),
      environmentalImpact: json['environmentalImpact'] ?? 'neutral',
      timeframe: json['timeframe'] ?? 'unknown',
      estimatedReturn: (json['estimatedReturn'] ?? 0.0).toDouble(),
      marketTiming: json['marketTiming'] ?? 'neutral',
      partsValue: (json['partsValue'] ?? 0.0).toDouble(),
      sustainabilityBenefit: json['sustainabilityBenefit'] ?? 'neutral',
    );
  }

  static ActionType _parseActionType(dynamic value) {
    if (value == null) return ActionType.other;
    final valueStr = value.toString().toLowerCase();

    for (final type in ActionType.values) {
      if (getEnumName(type).toLowerCase() == valueStr) {
        return type;
      }
    }
    return ActionType.other;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': getEnumName(type),
      'priority': priority,
      'costBenefitRatio': costBenefitRatio,
      'environmentalImpact': environmentalImpact,
      'timeframe': timeframe,
      'estimatedReturn': estimatedReturn,
      'marketTiming': marketTiming,
      'partsValue': partsValue,
      'sustainabilityBenefit': sustainabilityBenefit,
    };
  }
}

enum ScreenCondition { excellent, good, fair, poor, cracked, unknown }

enum HardwareCondition { excellent, good, fair, poor, damaged, unknown }

enum ActionType { repair, replace, donate, recycle, sell, other }
