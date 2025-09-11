import 'package:ayoayo/models/device_passport.dart';

enum ProjectStatus { planning, inProgress, completed, paused }

enum DifficultyLevel { beginner, intermediate, advanced, expert }

enum ProjectCategory { decor, functional, wearable, art, tech, other }

class UpcyclingProject {
  final String id;
  final String creatorId;
  final DevicePassport sourceDevice;
  final ProjectCategory category;
  final DifficultyLevel difficulty;
  final String title;
  final String description;
  final String aiGeneratedDescription;
  final List<String> imageUrls;
  final List<String> materialsNeeded;
  final List<String> toolsRequired;
  final List<ProjectStep> steps;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final int estimatedHours;
  final double estimatedCost;
  final List<String> tags;
  final Map<String, dynamic>? aiInsights;
  final double? environmentalImpact;
  final bool isPublic;
  final int? likesCount;
  final int? viewsCount;

  UpcyclingProject({
    required this.id,
    required this.creatorId,
    required this.sourceDevice,
    required this.category,
    required this.difficulty,
    required this.title,
    required this.description,
    required this.aiGeneratedDescription,
    required this.imageUrls,
    required this.materialsNeeded,
    required this.toolsRequired,
    required this.steps,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
    required this.estimatedHours,
    required this.estimatedCost,
    required this.tags,
    this.aiInsights,
    this.environmentalImpact,
    this.isPublic = true,
    this.likesCount = 0,
    this.viewsCount = 0,
  });

  factory UpcyclingProject.fromJson(Map<String, dynamic> json) {
    return UpcyclingProject(
      id: json['id'] ?? '',
      creatorId: json['creatorId'] ?? '',
      sourceDevice: DevicePassport.fromJson(json['sourceDevice'] ?? {}),
      category: ProjectCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => ProjectCategory.other,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.toString() == json['difficulty'],
        orElse: () => DifficultyLevel.intermediate,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      aiGeneratedDescription: json['aiGeneratedDescription'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      materialsNeeded: List<String>.from(json['materialsNeeded'] ?? []),
      toolsRequired: List<String>.from(json['toolsRequired'] ?? []),
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map((step) => ProjectStep.fromJson(step))
              .toList() ??
          [],
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      estimatedHours: json['estimatedHours'] ?? 0,
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      aiInsights: json['aiInsights'],
      environmentalImpact: json['environmentalImpact']?.toDouble(),
      isPublic: json['isPublic'] ?? true,
      likesCount: json['likesCount'] ?? 0,
      viewsCount: json['viewsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'sourceDevice': sourceDevice.toJson(),
      'category': category.toString(),
      'difficulty': difficulty.toString(),
      'title': title,
      'description': description,
      'aiGeneratedDescription': aiGeneratedDescription,
      'imageUrls': imageUrls,
      'materialsNeeded': materialsNeeded,
      'toolsRequired': toolsRequired,
      'steps': steps.map((step) => step.toJson()).toList(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'estimatedHours': estimatedHours,
      'estimatedCost': estimatedCost,
      'tags': tags,
      'aiInsights': aiInsights,
      'environmentalImpact': environmentalImpact,
      'isPublic': isPublic,
      'likesCount': likesCount,
      'viewsCount': viewsCount,
    };
  }

  // Get completion percentage based on status
  double get completionPercentage {
    switch (status) {
      case ProjectStatus.completed:
        return 100.0;
      case ProjectStatus.inProgress:
        return 50.0; // Could be more sophisticated
      case ProjectStatus.planning:
        return 10.0;
      case ProjectStatus.paused:
        return 25.0;
    }
  }

  // Check if project is overdue
  bool get isOverdue {
    if (status == ProjectStatus.completed || status == ProjectStatus.paused) {
      return false;
    }
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation > (estimatedHours / 2); // Rough estimate
  }

  // Get total steps count
  int get totalSteps => steps.length;

  // Get completed steps count (simplified)
  int get completedSteps {
    if (status == ProjectStatus.completed) return totalSteps;
    if (status == ProjectStatus.inProgress) return (totalSteps * 0.6).round();
    return 0;
  }
}

class ProjectStep {
  final int stepNumber;
  final String title;
  final String description;
  final List<String> imageUrls;
  final int estimatedMinutes;
  final List<String> materialsForStep;
  final bool isCompleted;
  final String? notes;

  ProjectStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.estimatedMinutes,
    required this.materialsForStep,
    this.isCompleted = false,
    this.notes,
  });

  factory ProjectStep.fromJson(Map<String, dynamic> json) {
    return ProjectStep(
      stepNumber: json['stepNumber'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      estimatedMinutes: json['estimatedMinutes'] ?? 0,
      materialsForStep: List<String>.from(json['materialsForStep'] ?? []),
      isCompleted: json['isCompleted'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'estimatedMinutes': estimatedMinutes,
      'materialsForStep': materialsForStep,
      'isCompleted': isCompleted,
      'notes': notes,
    };
  }
}

class MaterialSuggestion {
  final String material;
  final String source;
  final double cost;
  final String availability;
  final String environmentalNotes;

  MaterialSuggestion({
    required this.material,
    required this.source,
    required this.cost,
    required this.availability,
    required this.environmentalNotes,
  });

  factory MaterialSuggestion.fromJson(Map<String, dynamic> json) {
    return MaterialSuggestion(
      material: json['material'] ?? '',
      source: json['source'] ?? '',
      cost: (json['cost'] ?? 0).toDouble(),
      availability: json['availability'] ?? '',
      environmentalNotes: json['environmentalNotes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'material': material,
      'source': source,
      'cost': cost,
      'availability': availability,
      'environmentalNotes': environmentalNotes,
    };
  }
}
