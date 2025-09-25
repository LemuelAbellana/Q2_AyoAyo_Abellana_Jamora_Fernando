import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ayoayo/models/upcycling_project.dart';
import 'package:ayoayo/models/device_passport.dart';

class AIUpcyclingService {
  final GenerativeModel _model;

  AIUpcyclingService(String apiKey)
    : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  /// Generate upcycling project ideas based on device components
  Future<List<ProjectIdea>> generateProjectIdeas(
    DevicePassport devicePassport,
  ) async {
    final prompt =
        '''
You are a creative upcycling expert specializing in electronics. Generate innovative project ideas for repurposing a ${devicePassport.deviceModel}.

Device Analysis:
- Model: ${devicePassport.deviceModel}
- Manufacturer: ${devicePassport.manufacturer}
- Year: ${devicePassport.yearOfRelease}
- OS: ${devicePassport.operatingSystem}
- Screen Condition: ${devicePassport.lastDiagnosis.deviceHealth.screenCondition.toString().split('.').last}
- Hardware Condition: ${devicePassport.lastDiagnosis.deviceHealth.hardwareCondition.toString().split('.').last}
- Hardware Issues: ${devicePassport.lastDiagnosis.deviceHealth.identifiedIssues.join(', ')}

Available Components:
- Screen/LCD panel
- Battery and charging components
- Camera modules
- Speakers/microphones
- Circuit boards and chips
- Plastic casing and frame
- Buttons and sensors
- Internal wiring and connectors

Generate 5-7 creative, feasible upcycling project ideas that:
1. Utilize the device's valuable components
2. Are appropriate for the device's condition
3. Have practical applications
4. Consider safety and environmental impact
5. Include difficulty level and required skills

For each idea, provide:
- Project title
- Difficulty level (beginner/intermediate/advanced)
- Required materials and tools
- Step-by-step instructions
- Estimated time and cost
- Environmental impact
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseProjectIdeas(response.text ?? '', devicePassport);
    } catch (e) {
      return _generateFallbackProjectIdeas(devicePassport);
    }
  }

  /// Generate detailed project steps for a specific idea
  Future<UpcyclingProject> generateDetailedProject(
    DevicePassport devicePassport,
    String projectIdea,
    DifficultyLevel difficulty,
  ) async {
    final prompt =
        '''
Create a detailed upcycling project plan for: "$projectIdea"

Device: ${devicePassport.deviceModel}
Difficulty Level: ${difficulty.toString().split('.').last}

Provide a complete project specification including:
1. Project title and description
2. Required materials and tools
3. Detailed step-by-step instructions
4. Safety precautions
5. Estimated time and cost
6. Skill requirements
7. Tips for success
8. Alternative approaches if needed

Ensure the project is:
- Safe to execute
- Environmentally responsible
- Technically feasible
- Educational and engaging
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseDetailedProject(
        response.text ?? '',
        devicePassport,
        projectIdea,
        difficulty,
      );
    } catch (e) {
      return _generateFallbackProject(devicePassport, projectIdea, difficulty);
    }
  }

  /// Analyze device for upcycling potential
  Future<UpcyclingAnalysis> analyzeUpcyclingPotential(
    DevicePassport devicePassport,
  ) async {
    final prompt =
        '''
Analyze this device for upcycling potential:

Device: ${devicePassport.deviceModel}
Condition: Screen - ${devicePassport.lastDiagnosis.deviceHealth.screenCondition}, Hardware - ${devicePassport.lastDiagnosis.deviceHealth.hardwareCondition}
Issues: ${devicePassport.lastDiagnosis.deviceHealth.identifiedIssues.join(', ')}

Evaluate:
1. Salvageable components and their value
2. Best upcycling applications
3. Required tools and skills
4. Safety considerations
5. Environmental impact assessment
6. Market potential for upcycled products
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseUpcyclingAnalysis(response.text ?? '', devicePassport);
    } catch (e) {
      return _generateFallbackAnalysis(devicePassport);
    }
  }

  /// Generate material sourcing suggestions
  Future<List<MaterialSuggestion>> suggestMaterials(
    UpcyclingProject project,
  ) async {
    final prompt =
        '''
For this upcycling project: "${project.title}"

Required Materials: ${project.materialsNeeded.join(', ')}
Tools Needed: ${project.toolsRequired.join(', ')}

Suggest:
1. Where to source additional materials affordably
2. Alternative materials that could work
3. Cost-effective substitutions
4. Eco-friendly sourcing options
5. Local availability considerations
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseMaterialSuggestions(response.text ?? '');
    } catch (e) {
      return _generateFallbackMaterialSuggestions(project);
    }
  }

  /// Generate project documentation and sharing content
  Future<ProjectDocumentation> generateDocumentation(
    UpcyclingProject project,
  ) async {
    final prompt =
        '''
Create comprehensive documentation for sharing this upcycling project:

Project: ${project.title}
Description: ${project.description}
Difficulty: ${project.difficulty.toString().split('.').last}
Time: ${project.estimatedHours} hours
Cost: ₱${project.estimatedCost}

Generate:
1. Engaging social media post
2. Detailed blog/tutorial content
3. Photo/video documentation tips
4. Community sharing suggestions
5. Monetization ideas if applicable
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseProjectDocumentation(response.text ?? '');
    } catch (e) {
      return _generateFallbackDocumentation(project);
    }
  }

  // Helper parsing methods
  List<ProjectIdea> _parseProjectIdeas(String content, DevicePassport device) {
    // Simple parsing - in production, use more sophisticated parsing
    final ideas = <ProjectIdea>[];

    // Extract project ideas from the content
    final sections = content.split('\n\n');

    for (final section in sections) {
      if (section.contains('Project') || section.contains('Idea')) {
        final lines = section.split('\n');
        if (lines.isNotEmpty) {
          final title = lines[0]
              .replaceAll('Project:', '')
              .replaceAll('Idea:', '')
              .trim();
          if (title.isNotEmpty && title.length > 10) {
            // Filter out headers
            ideas.add(
              ProjectIdea(
                title: title,
                description: section,
                difficulty: _determineDifficultyFromTitle(title),
                estimatedTime: _estimateTimeFromTitle(title),
                estimatedCost: _estimateCostFromTitle(title) + (ideas.length * 500),
                requiredSkills: _getRequiredSkillsFromTitle(title),
                environmentalImpact: 'High - repurposes electronic waste',
                materials: _getMaterialsFromTitle(title, device),
              ),
            );
          }
        }
      }
    }

    // Ensure we have at least some ideas
    if (ideas.isEmpty) {
      return _generateFallbackProjectIdeas(device);
    }

    return ideas.take(6).toList(); // Limit to 6 ideas
  }

  DifficultyLevel _determineDifficultyFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('mirror') || lowerTitle.contains('hub') || lowerTitle.contains('emulator')) {
      return DifficultyLevel.advanced;
    } else if (lowerTitle.contains('speaker') || lowerTitle.contains('charger') || lowerTitle.contains('camera')) {
      return DifficultyLevel.intermediate;
    } else {
      return DifficultyLevel.beginner;
    }
  }

  String _estimateTimeFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('mirror') || lowerTitle.contains('hub')) {
      return '8-12 hours';
    } else if (lowerTitle.contains('speaker') || lowerTitle.contains('charger')) {
      return '4-6 hours';
    } else {
      return '2-4 hours';
    }
  }

  double _estimateCostFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('mirror') || lowerTitle.contains('hub')) {
      return 4000;
    } else if (lowerTitle.contains('speaker') || lowerTitle.contains('charger')) {
      return 2500;
    } else {
      return 1500;
    }
  }

  List<String> _getRequiredSkillsFromTitle(String title) {
    final lowerTitle = title.toLowerCase();
    final skills = <String>['Basic electronics'];

    if (lowerTitle.contains('speaker') || lowerTitle.contains('charger')) {
      skills.addAll(['Soldering', 'Circuit design']);
    }
    if (lowerTitle.contains('frame') || lowerTitle.contains('mirror')) {
      skills.addAll(['Woodworking', 'Assembly']);
    }
    if (lowerTitle.contains('hub') || lowerTitle.contains('emulator')) {
      skills.addAll(['Programming', 'Advanced electronics']);
    }

    return skills;
  }

  List<String> _getMaterialsFromTitle(String title, DevicePassport device) {
    final lowerTitle = title.toLowerCase();
    final materials = <String>[];

    // Base materials from device
    materials.addAll([
      'Device components (${device.deviceModel})',
      'Screwdriver set',
      'Wire strippers',
    ]);

    // Project-specific materials
    if (lowerTitle.contains('frame')) {
      materials.addAll([
        'Wood frame (12x8 inches)',
        'Picture frame glass',
        'LED backlight strip',
        'Power adapter (5V)',
      ]);
    } else if (lowerTitle.contains('speaker')) {
      materials.addAll([
        'Bluetooth audio module',
        'Wooden enclosure',
        'Fabric grille cloth',
        'Rubber feet pads',
      ]);
    } else if (lowerTitle.contains('charger') || lowerTitle.contains('power bank')) {
      materials.addAll([
        'USB output module',
        'Charging circuit board',
        'Protective case',
        'LED indicator lights',
      ]);
    } else if (lowerTitle.contains('camera')) {
      materials.addAll([
        'WiFi module',
        'Motion sensor',
        'Mounting bracket',
        'Weatherproof housing',
      ]);
    } else if (lowerTitle.contains('mirror')) {
      materials.addAll([
        'Two-way mirror (24x16 inches)',
        'Wooden frame',
        'Raspberry Pi or similar',
        'HDMI cable',
        'Touch sensor (optional)',
      ]);
    } else if (lowerTitle.contains('hub')) {
      materials.addAll([
        'Smart home controller',
        'WiFi antenna',
        'Ventilation fan',
        'Status LED matrix',
      ]);
    }

    return materials;
  }

  UpcyclingProject _parseDetailedProject(
    String content,
    DevicePassport device,
    String idea,
    DifficultyLevel difficulty,
  ) {
    // Parse the detailed project from AI response
    final steps = <ProjectStep>[];
    final materials = <String>[];
    final tools = <String>[];

    final lines = content.split('\n');

    // Extract materials and tools
    for (final line in lines) {
      if (line.toLowerCase().contains('material')) {
        materials.add(
          line.replaceAll('Materials:', '').replaceAll('Material:', '').trim(),
        );
      }
      if (line.toLowerCase().contains('tool')) {
        tools.add(line.replaceAll('Tools:', '').replaceAll('Tool:', '').trim());
      }
    }

    // Create basic steps (simplified)
    steps.addAll([
      ProjectStep(
        stepNumber: 1,
        title: 'Disassembly',
        description:
            'Carefully disassemble the device and identify reusable components',
        imageUrls: [],
        estimatedMinutes: 60,
        materialsForStep: ['Device components'],
      ),
      ProjectStep(
        stepNumber: 2,
        title: 'Preparation',
        description: 'Clean and prepare components for the project',
        imageUrls: [],
        estimatedMinutes: 30,
        materialsForStep: ['Cleaning supplies'],
      ),
      ProjectStep(
        stepNumber: 3,
        title: 'Assembly',
        description: 'Assemble the upcycled project according to the design',
        imageUrls: [],
        estimatedMinutes: 120,
        materialsForStep: materials,
      ),
    ]);

    return UpcyclingProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      creatorId: 'user',
      sourceDevice: device,
      category: ProjectCategory.other,
      difficulty: difficulty,
      title: idea,
      description: content.split('\n\n').isNotEmpty
          ? content.split('\n\n')[0]
          : 'Creative upcycling project',
      aiGeneratedDescription: content,
      imageUrls: [],
      materialsNeeded: materials,
      toolsRequired: tools,
      steps: steps,
      status: ProjectStatus.planning,
      createdAt: DateTime.now(),
      estimatedHours: 6,
      estimatedCost: 3000,
      tags: ['upcycling', 'electronics', 'sustainable'],
    );
  }

  UpcyclingAnalysis _parseUpcyclingAnalysis(
    String content,
    DevicePassport device,
  ) {
    return UpcyclingAnalysis(
      salvageableComponents: [
        'Screen',
        'Battery',
        'Circuit board',
        'Camera',
        'Speakers',
      ],
      bestApplications: [
        'Decorative items',
        'Functional gadgets',
        'Art installations',
      ],
      requiredTools: ['Screwdrivers', 'Pliers', 'Soldering iron'],
      safetyConsiderations: [
        'Avoid high voltage components',
        'Wear protective gear',
      ],
      environmentalImpact: 8.5,
      marketPotential: 'Medium - niche creative market',
    );
  }

  List<MaterialSuggestion> _parseMaterialSuggestions(String content) {
    return [
      MaterialSuggestion(
        material: 'Wooden base/frame',
        source: 'Local carpenter or recycled wood',
        cost: 1500,
        availability: 'Readily available locally',
        environmentalNotes:
            'Use reclaimed wood for better environmental impact',
      ),
      MaterialSuggestion(
        material: 'LED strips',
        source: 'Electronics market or online',
        cost: 800,
        availability: 'Available in major cities',
        environmentalNotes: 'Choose energy-efficient LEDs',
      ),
    ];
  }

  ProjectDocumentation _parseProjectDocumentation(String content) {
    return ProjectDocumentation(
      socialMediaPost:
          'Check out this amazing upcycling project! ♻️ #Upcycling #Sustainable',
      tutorialContent: content,
      documentationTips: [
        'Take progress photos',
        'Document challenges and solutions',
      ],
      sharingSuggestions: [
        'Post on social media',
        'Share with local maker communities',
      ],
      monetizationIdeas: ['Sell similar projects', 'Offer upcycling workshops'],
    );
  }

  // Fallback methods
  List<ProjectIdea> _generateFallbackProjectIdeas(DevicePassport device) {
    return [
      ProjectIdea(
        title: 'LED Picture Frame with Device Screen',
        description:
            'Transform the device screen into an illuminated picture frame',
        difficulty: DifficultyLevel.intermediate,
        estimatedTime: '3-5 hours',
        estimatedCost: 2500,
        requiredSkills: ['Basic electronics', 'Woodworking'],
        environmentalImpact: 'High - reuses display technology',
        materials: [
          'Device components (${device.deviceModel})',
          'Wood frame (12x8 inches)',
          'Picture frame glass',
          'LED backlight strip',
          'Power adapter (5V)',
          'Screwdriver set',
          'Wire strippers',
        ],
      ),
      ProjectIdea(
        title: 'Portable Phone Charger Bank',
        description: 'Create a custom power bank using the device battery',
        difficulty: DifficultyLevel.advanced,
        estimatedTime: '4-6 hours',
        estimatedCost: 1500,
        requiredSkills: ['Electronics soldering', 'Circuit design'],
        environmentalImpact: 'Medium - reuses battery technology',
        materials: [
          'Device components (${device.deviceModel})',
          'USB output module',
          'Charging circuit board',
          'Protective case',
          'LED indicator lights',
          'Screwdriver set',
          'Soldering iron',
        ],
      ),
      ProjectIdea(
        title: 'Bluetooth Speaker from Phone Components',
        description: 'Build a custom speaker using phone audio components',
        difficulty: DifficultyLevel.intermediate,
        estimatedTime: '5-7 hours',
        estimatedCost: 3000,
        requiredSkills: ['Electronics', 'Enclosure design'],
        environmentalImpact: 'High - reuses audio technology',
        materials: [
          'Device components (${device.deviceModel})',
          'Bluetooth audio module',
          'Wooden enclosure',
          'Fabric grille cloth',
          'Rubber feet pads',
          'Screwdriver set',
          'Drill',
        ],
      ),
      ProjectIdea(
        title: 'Digital Photo Frame',
        description: 'Convert the device into a digital photo display',
        difficulty: DifficultyLevel.beginner,
        estimatedTime: '2-4 hours',
        estimatedCost: 1000,
        requiredSkills: ['Basic assembly', 'Software setup'],
        environmentalImpact: 'High - extends device lifespan',
        materials: [
          'Device components (${device.deviceModel})',
          'Simple frame stand',
          'Power cable',
          'SD card (optional)',
          'Screwdriver set',
        ],
      ),
      ProjectIdea(
        title: 'Smart Mirror with Touch Interface',
        description: 'Create an interactive mirror using the device screen',
        difficulty: DifficultyLevel.advanced,
        estimatedTime: '8-12 hours',
        estimatedCost: 4000,
        requiredSkills: ['Electronics', 'Programming', 'Mirror construction'],
        environmentalImpact: 'Very High - innovative reuse',
        materials: [
          'Device components (${device.deviceModel})',
          'Two-way mirror (24x16 inches)',
          'Wooden frame',
          'Raspberry Pi or similar',
          'HDMI cable',
          'Touch sensor (optional)',
          'Screwdriver set',
          'Programming tools',
        ],
      ),
    ];
  }

  UpcyclingProject _generateFallbackProject(
    DevicePassport device,
    String idea,
    DifficultyLevel difficulty,
  ) {
    return UpcyclingProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      creatorId: 'user',
      sourceDevice: device,
      category: ProjectCategory.other,
      difficulty: difficulty,
      title: idea,
      description: 'Creative upcycling project using device components',
      aiGeneratedDescription:
          'This project transforms your old device into something new and useful',
      imageUrls: [],
      materialsNeeded: ['Wood/plastic for frame', 'Wiring', 'Basic tools'],
      toolsRequired: ['Screwdriver', 'Pliers', 'Glue gun'],
      steps: [
        ProjectStep(
          stepNumber: 1,
          title: 'Safety First',
          description:
              'Ensure device is powered off and battery is safely removed',
          imageUrls: [],
          estimatedMinutes: 15,
          materialsForStep: [],
        ),
        ProjectStep(
          stepNumber: 2,
          title: 'Disassemble Device',
          description: 'Carefully take apart the device to access components',
          imageUrls: [],
          estimatedMinutes: 45,
          materialsForStep: ['Screwdriver set'],
        ),
        ProjectStep(
          stepNumber: 3,
          title: 'Prepare Components',
          description: 'Clean and prepare the components you want to reuse',
          imageUrls: [],
          estimatedMinutes: 30,
          materialsForStep: ['Cleaning supplies'],
        ),
        ProjectStep(
          stepNumber: 4,
          title: 'Build New Project',
          description:
              'Assemble your upcycling project using the device components',
          imageUrls: [],
          estimatedMinutes: 120,
          materialsForStep: ['Additional materials as needed'],
        ),
      ],
      status: ProjectStatus.planning,
      createdAt: DateTime.now(),
      estimatedHours: 4,
      estimatedCost: 2000,
      tags: ['upcycling', 'electronics', 'diy'],
    );
  }

  UpcyclingAnalysis _generateFallbackAnalysis(DevicePassport device) {
    return UpcyclingAnalysis(
      salvageableComponents: [
        'Display screen',
        'Battery',
        'Camera',
        'Speakers',
        'Circuit boards',
      ],
      bestApplications: [
        'Custom electronics',
        'Art installations',
        'Educational projects',
      ],
      requiredTools: [
        'Screwdriver set',
        'Pliers',
        'Soldering iron',
        'Multimeter',
      ],
      safetyConsiderations: [
        'Handle batteries carefully',
        'Avoid damaged components',
        'Use protective gear',
      ],
      environmentalImpact: 7.5,
      marketPotential: 'Good for creative markets and maker communities',
    );
  }

  List<MaterialSuggestion> _generateFallbackMaterialSuggestions(
    UpcyclingProject project,
  ) {
    return [
      MaterialSuggestion(
        material: 'Recycled wood',
        source: 'Local recycling centers or carpenter shops',
        cost: 500,
        availability: 'Widely available',
        environmentalNotes: 'Reduces waste and carbon footprint',
      ),
      MaterialSuggestion(
        material: 'LED lights',
        source: 'Electronics markets',
        cost: 300,
        availability: 'Available in urban areas',
        environmentalNotes: 'Choose energy-efficient options',
      ),
      MaterialSuggestion(
        material: 'Basic wiring',
        source: 'Electronics stores or online',
        cost: 200,
        availability: 'Readily available',
        environmentalNotes: 'Minimal environmental impact',
      ),
    ];
  }

  ProjectDocumentation _generateFallbackDocumentation(
    UpcyclingProject project,
  ) {
    return ProjectDocumentation(
      socialMediaPost:
          'Just completed an amazing upcycling project using an old ${project.sourceDevice.deviceModel}! '
          'Transforming e-waste into something beautiful and functional. ♻️ #Upcycling #SustainableLiving',
      tutorialContent: 'Step-by-step guide to upcycling your old device...',
      documentationTips: [
        'Take photos at each major step',
        'Note any challenges you encountered',
        'Document the final result from multiple angles',
        'Include material costs and time spent',
      ],
      sharingSuggestions: [
        'Share on Instagram and TikTok with #Upcycling',
        'Post in local maker/electronics communities',
        'Create a tutorial video for YouTube',
        'Share with environmental groups',
      ],
      monetizationIdeas: [
        'Sell completed projects on local marketplaces',
        'Offer upcycling workshops',
        'Create and sell digital templates',
        'Partner with local businesses for custom projects',
      ],
    );
  }
}

// Data classes for AI responses
class ProjectIdea {
  final String title;
  final String description;
  final DifficultyLevel difficulty;
  final String estimatedTime;
  final double estimatedCost;
  final List<String> requiredSkills;
  final String environmentalImpact;
  final List<String> materials;

  ProjectIdea({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.estimatedTime,
    required this.estimatedCost,
    required this.requiredSkills,
    required this.environmentalImpact,
    this.materials = const [],
  });
}

class UpcyclingAnalysis {
  final List<String> salvageableComponents;
  final List<String> bestApplications;
  final List<String> requiredTools;
  final List<String> safetyConsiderations;
  final double environmentalImpact;
  final String marketPotential;

  UpcyclingAnalysis({
    required this.salvageableComponents,
    required this.bestApplications,
    required this.requiredTools,
    required this.safetyConsiderations,
    required this.environmentalImpact,
    required this.marketPotential,
  });
}

class ProjectDocumentation {
  final String socialMediaPost;
  final String tutorialContent;
  final List<String> documentationTips;
  final List<String> sharingSuggestions;
  final List<String> monetizationIdeas;

  ProjectDocumentation({
    required this.socialMediaPost,
    required this.tutorialContent,
    required this.documentationTips,
    required this.sharingSuggestions,
    required this.monetizationIdeas,
  });
}
