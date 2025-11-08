import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ayoayo/models/upcycling_project.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/services/ai_upcycling_service.dart';
import 'package:ayoayo/services/database_service.dart';
import 'package:ayoayo/utils/enum_helpers.dart';

class UpcyclingProvider extends ChangeNotifier {
  final AIUpcyclingService _aiService;
  final DatabaseService _dbService = DatabaseService();

  UpcyclingProvider(String apiKey) : _aiService = AIUpcyclingService(apiKey);

  // State management
  List<UpcyclingProject> _projects = [];
  List<UpcyclingProject> _userProjects = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<ProjectIdea> _currentIdeas = [];

  // Getters
  List<UpcyclingProject> get projects => _projects;
  List<UpcyclingProject> get userProjects => _userProjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProjectIdea> get currentIdeas => _currentIdeas;

  // Filtered projects
  List<UpcyclingProject> get publicProjects =>
      _projects.where((project) => project.isPublic).toList();

  List<UpcyclingProject> get completedProjects => _userProjects
      .where((project) => project.status == ProjectStatus.completed)
      .toList();

  List<UpcyclingProject> get inProgressProjects => _userProjects
      .where((project) => project.status == ProjectStatus.inProgress)
      .toList();

  // Methods
  Future<void> loadProjects() async {
    _setLoading(true);
    try {
      final projectsData = await _dbService.getUpcyclingProjects();
      _projects = projectsData.map((data) => _upcyclingProjectFromMap(data)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load projects: $e';
      _projects = _generateMockProjects();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserProjects(String userId) async {
    _setLoading(true);
    try {
      final projectsData = await _dbService.getUpcyclingProjects(creatorId: userId);
      _userProjects = projectsData.map((data) => _upcyclingProjectFromMap(data)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load user projects: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<List<ProjectIdea>> generateProjectIdeas(
    DevicePassport devicePassport,
  ) async {
    _setLoading(true);
    try {
      _currentIdeas = await _aiService.generateProjectIdeas(devicePassport);
      _errorMessage = null;
      return _currentIdeas;
    } catch (e) {
      _errorMessage = 'Failed to generate project ideas: $e';
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<UpcyclingProject?> createProject({
    required DevicePassport devicePassport,
    required String projectIdea,
    required DifficultyLevel difficulty,
    required String creatorId,
  }) async {
    _setLoading(true);
    try {
      final project = await _aiService.generateDetailedProject(
        devicePassport,
        projectIdea,
        difficulty,
      );

      // Update project with proper ID and creator
      final newProject = UpcyclingProject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        creatorId: creatorId,
        sourceDevice: project.sourceDevice,
        category: project.category,
        difficulty: project.difficulty,
        title: project.title,
        description: project.description,
        aiGeneratedDescription: project.aiGeneratedDescription,
        imageUrls: project.imageUrls,
        materialsNeeded: project.materialsNeeded,
        toolsRequired: project.toolsRequired,
        steps: project.steps,
        status: ProjectStatus.planning,
        createdAt: DateTime.now(),
        estimatedHours: project.estimatedHours,
        estimatedCost: project.estimatedCost,
        tags: project.tags,
        aiInsights: project.aiInsights,
        environmentalImpact: project.environmentalImpact,
        isPublic: true,
        likesCount: 0,
        viewsCount: 0,
      );

      // Save to database
      final projectData = _upcyclingProjectToMap(newProject);
      await _dbService.saveUpcyclingProject(projectData);

      _projects.add(newProject);
      _userProjects.add(newProject);

      notifyListeners();
      return newProject;
    } catch (e) {
      _errorMessage = 'Failed to create project: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProjectStatus(
    String projectId,
    ProjectStatus status,
  ) async {
    try {
      final index = _projects.indexWhere((project) => project.id == projectId);
      if (index != -1) {
        final updatedProject = _projects[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
          completedAt: status == ProjectStatus.completed
              ? DateTime.now()
              : null,
        );

        _projects[index] = updatedProject;

        final userIndex = _userProjects.indexWhere(
          (project) => project.id == projectId,
        );
        if (userIndex != -1) {
          _userProjects[userIndex] = updatedProject;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update project: $e';
      return false;
    }
  }

  Future<bool> updateProjectStep(
    String projectId,
    int stepNumber,
    bool isCompleted,
    String? notes,
  ) async {
    try {
      final projectIndex = _projects.indexWhere(
        (project) => project.id == projectId,
      );
      if (projectIndex != -1) {
        final project = _projects[projectIndex];
        final updatedSteps = List<ProjectStep>.from(project.steps);

        final stepIndex = updatedSteps.indexWhere(
          (step) => step.stepNumber == stepNumber,
        );
        if (stepIndex != -1) {
          updatedSteps[stepIndex] = ProjectStep(
            stepNumber: updatedSteps[stepIndex].stepNumber,
            title: updatedSteps[stepIndex].title,
            description: updatedSteps[stepIndex].description,
            imageUrls: updatedSteps[stepIndex].imageUrls,
            estimatedMinutes: updatedSteps[stepIndex].estimatedMinutes,
            materialsForStep: updatedSteps[stepIndex].materialsForStep,
            isCompleted: isCompleted,
            notes: notes ?? updatedSteps[stepIndex].notes,
          );

          final updatedProject = project.copyWith(
            steps: updatedSteps,
            updatedAt: DateTime.now(),
          );

          _projects[projectIndex] = updatedProject;

          final userIndex = _userProjects.indexWhere(
            (project) => project.id == projectId,
          );
          if (userIndex != -1) {
            _userProjects[userIndex] = updatedProject;
          }

          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update project step: $e';
      return false;
    }
  }

  Future<UpcyclingAnalysis> analyzeDevice(DevicePassport devicePassport) async {
    try {
      return await _aiService.analyzeUpcyclingPotential(devicePassport);
    } catch (e) {
      return UpcyclingAnalysis(
        salvageableComponents: ['Screen', 'Battery', 'Circuit board'],
        bestApplications: ['Decorative items', 'Functional electronics'],
        requiredTools: ['Screwdrivers', 'Pliers'],
        safetyConsiderations: [
          'Handle components carefully',
          'Avoid damaged parts',
        ],
        environmentalImpact: 7.0,
        marketPotential: 'Good for creative markets',
      );
    }
  }

  Future<List<MaterialSuggestion>> getMaterialSuggestions(
    UpcyclingProject project,
  ) async {
    try {
      return await _aiService.suggestMaterials(project);
    } catch (e) {
      return [];
    }
  }

  Future<ProjectDocumentation> generateDocumentation(
    UpcyclingProject project,
  ) async {
    try {
      return await _aiService.generateDocumentation(project);
    } catch (e) {
      return ProjectDocumentation(
        socialMediaPost: 'Amazing upcycling project completed! #Upcycling',
        tutorialContent: 'Step by step guide...',
        documentationTips: ['Take progress photos', 'Document challenges'],
        sharingSuggestions: [
          'Share on social media',
          'Post in maker communities',
        ],
        monetizationIdeas: ['Sell similar projects', 'Offer workshops'],
      );
    }
  }

  void searchProjects(String query) {
    // In a real app, this would filter projects based on search query
    notifyListeners();
  }

  void filterByCategory(ProjectCategory category) {
    // Filter projects by category
    notifyListeners();
  }

  void filterByDifficulty(DifficultyLevel difficulty) {
    // Filter projects by difficulty
    notifyListeners();
  }

  void sortProjects(String sortBy) {
    switch (sortBy) {
      case 'newest':
        _projects.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        _projects.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'most_liked':
        _projects.sort(
          (a, b) => (b.likesCount ?? 0).compareTo(a.likesCount ?? 0),
        );
        break;
      case 'most_viewed':
        _projects.sort(
          (a, b) => (b.viewsCount ?? 0).compareTo(a.viewsCount ?? 0),
        );
        break;
    }
    notifyListeners();
  }

  Future<bool> likeProject(String projectId) async {
    try {
      final index = _projects.indexWhere((project) => project.id == projectId);
      if (index != -1) {
        final project = _projects[index];
        final updatedProject = project.copyWith(
          likesCount: (project.likesCount ?? 0) + 1,
        );

        _projects[index] = updatedProject;

        final userIndex = _userProjects.indexWhere(
          (project) => project.id == projectId,
        );
        if (userIndex != -1) {
          _userProjects[userIndex] = updatedProject;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to like project: $e';
      return false;
    }
  }

  Future<bool> viewProject(String projectId) async {
    try {
      final index = _projects.indexWhere((project) => project.id == projectId);
      if (index != -1) {
        final project = _projects[index];
        final updatedProject = project.copyWith(
          viewsCount: (project.viewsCount ?? 0) + 1,
        );

        _projects[index] = updatedProject;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  List<UpcyclingProject> _generateMockProjects() {
    // Generate some mock projects for demonstration
    return [
      // Mock projects would be created here
    ];
  }

  // Helper methods for database conversion
  Map<String, dynamic> _upcyclingProjectToMap(UpcyclingProject project) {
    return {
      'project_uuid': project.id,
      'creator_id': project.creatorId,
      'device_passport_id': 1, // Default for now
      'title': project.title,
      'description': project.description,
      'difficulty_level': getEnumName(project.difficulty),
      'category': getEnumName(project.category),
      'status': getEnumName(project.status),
      'materials_needed': project.materialsNeeded,
      'tools_required': project.toolsRequired,
      'estimated_hours': project.estimatedHours,
      'estimated_cost': project.estimatedCost,
      'tags': project.tags,
      'ai_insights': project.aiInsights ?? {},
      'environmental_impact': project.environmentalImpact ?? 0.0,
      'is_public': project.isPublic,
      'likes_count': project.likesCount ?? 0,
      'views_count': project.viewsCount ?? 0,
      'created_at': project.createdAt.toIso8601String(),
      'updated_at': project.updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  UpcyclingProject _upcyclingProjectFromMap(Map<String, dynamic> data) {
    return UpcyclingProject(
      id: data['project_uuid'] ?? data['id']?.toString() ?? '',
      creatorId: data['creator_id']?.toString() ?? '',
      sourceDevice: DevicePassport(
        id: 'temp',
        userId: data['creator_id']?.toString() ?? '',
        deviceModel: 'Unknown Device',
        manufacturer: 'Unknown',
        yearOfRelease: DateTime.now().year,
        operatingSystem: 'Android',
        imageUrls: [],
        lastDiagnosis: DiagnosisResult(
          deviceModel: 'Unknown Device',
          deviceHealth: DeviceHealth(
            screenCondition: ScreenCondition.unknown,
            hardwareCondition: HardwareCondition.unknown,
            identifiedIssues: [],
          ),
          valueEstimation: ValueEstimation(
            currentValue: 0,
            postRepairValue: 0,
            partsValue: 0,
            repairCost: 0,
          ),
          recommendations: [],
          aiAnalysis: '',
          confidenceScore: 0.0,
        ),
      ),
      category: _parseProjectCategory(data['category'] ?? 'other'),
      difficulty: _parseDifficultyLevel(data['difficulty_level'] ?? 'beginner'),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      aiGeneratedDescription: data['ai_generated_description'] ?? '',
      imageUrls: data['image_urls'] != null ? List<String>.from(data['image_urls']) : [],
      materialsNeeded: data['materials_needed'] != null
          ? (data['materials_needed'] is String
              ? List<String>.from(json.decode(data['materials_needed']))
              : List<String>.from(data['materials_needed']))
          : [],
      toolsRequired: data['tools_required'] != null
          ? (data['tools_required'] is String
              ? List<String>.from(json.decode(data['tools_required']))
              : List<String>.from(data['tools_required']))
          : [],
      steps: [], // Would need to load steps separately
      status: _parseProjectStatus(data['status'] ?? 'planning'),
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updated_at'] ?? ''),
      estimatedHours: data['estimated_hours'] ?? 0,
      estimatedCost: (data['estimated_cost'] ?? 0).toDouble(),
      tags: data['tags'] != null
          ? (data['tags'] is String
              ? List<String>.from(json.decode(data['tags']))
              : List<String>.from(data['tags']))
          : [],
      aiInsights: data['ai_insights'] != null
          ? (data['ai_insights'] is String
              ? Map<String, dynamic>.from(json.decode(data['ai_insights']))
              : Map<String, dynamic>.from(data['ai_insights']))
          : {},
      environmentalImpact: (data['environmental_impact'] ?? 0.0).toDouble(),
      isPublic: data['is_public'] == 1 || data['is_public'] == true,
      likesCount: data['likes_count'] ?? 0,
      viewsCount: data['views_count'] ?? 0,
    );
  }

  ProjectCategory _parseProjectCategory(String category) {
    switch (category.toLowerCase()) {
      case 'functional':
        return ProjectCategory.functional;
      case 'decor':
        return ProjectCategory.decor;
      case 'wearable':
        return ProjectCategory.wearable;
      case 'tech':
        return ProjectCategory.tech;
      case 'art':
        return ProjectCategory.art;
      default:
        return ProjectCategory.other;
    }
  }

  DifficultyLevel _parseDifficultyLevel(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return DifficultyLevel.beginner;
      case 'intermediate':
        return DifficultyLevel.intermediate;
      case 'advanced':
        return DifficultyLevel.advanced;
      case 'expert':
        return DifficultyLevel.expert;
      default:
        return DifficultyLevel.beginner;
    }
  }

  ProjectStatus _parseProjectStatus(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return ProjectStatus.planning;
      case 'inprogress':
      case 'in_progress':
        return ProjectStatus.inProgress;
      case 'completed':
        return ProjectStatus.completed;
      case 'paused':
        return ProjectStatus.paused;
      default:
        return ProjectStatus.planning;
    }
  }
}

// Extension to copy UpcyclingProject with modifications
extension UpcyclingProjectCopyWith on UpcyclingProject {
  UpcyclingProject copyWith({
    String? id,
    String? creatorId,
    DevicePassport? sourceDevice,
    ProjectCategory? category,
    DifficultyLevel? difficulty,
    String? title,
    String? description,
    String? aiGeneratedDescription,
    List<String>? imageUrls,
    List<String>? materialsNeeded,
    List<String>? toolsRequired,
    List<ProjectStep>? steps,
    ProjectStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    int? estimatedHours,
    double? estimatedCost,
    List<String>? tags,
    Map<String, dynamic>? aiInsights,
    double? environmentalImpact,
    bool? isPublic,
    int? likesCount,
    int? viewsCount,
  }) {
    return UpcyclingProject(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      sourceDevice: sourceDevice ?? this.sourceDevice,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      title: title ?? this.title,
      description: description ?? this.description,
      aiGeneratedDescription:
          aiGeneratedDescription ?? this.aiGeneratedDescription,
      imageUrls: imageUrls ?? this.imageUrls,
      materialsNeeded: materialsNeeded ?? this.materialsNeeded,
      toolsRequired: toolsRequired ?? this.toolsRequired,
      steps: steps ?? this.steps,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      tags: tags ?? this.tags,
      aiInsights: aiInsights ?? this.aiInsights,
      environmentalImpact: environmentalImpact ?? this.environmentalImpact,
      isPublic: isPublic ?? this.isPublic,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
    );
  }
}
