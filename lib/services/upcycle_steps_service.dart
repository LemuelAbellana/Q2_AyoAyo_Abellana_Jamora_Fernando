import '../models/device_diagnosis.dart';
import '../services/device_specifications_service.dart';

class UpcycleStep {
  final int stepNumber;
  final String title;
  final String description;
  final List<String> materials;
  final List<String> tools;
  final int estimatedMinutes;
  final String difficulty;
  final String safetyNote;
  final List<String> tips;

  UpcycleStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    this.materials = const [],
    this.tools = const [],
    this.estimatedMinutes = 30,
    this.difficulty = 'Medium',
    this.safetyNote = '',
    this.tips = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'description': description,
      'materials': materials,
      'tools': tools,
      'estimatedMinutes': estimatedMinutes,
      'difficulty': difficulty,
      'safetyNote': safetyNote,
      'tips': tips,
    };
  }
}

class UpcycleProject {
  final String id;
  final String title;
  final String description;
  final String deviceModel;
  final String difficulty;
  final int totalEstimatedHours;
  final double estimatedCost;
  final List<String> componentsUsed;
  final List<UpcycleStep> steps;
  final String category;
  final double sustainabilityScore;
  final String environmentalImpact;

  UpcycleProject({
    required this.id,
    required this.title,
    required this.description,
    required this.deviceModel,
    this.difficulty = 'Medium',
    this.totalEstimatedHours = 4,
    this.estimatedCost = 500.0,
    this.componentsUsed = const [],
    this.steps = const [],
    this.category = 'Electronics',
    this.sustainabilityScore = 7.5,
    this.environmentalImpact = 'Positive - Reduces e-waste',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deviceModel': deviceModel,
      'difficulty': difficulty,
      'totalEstimatedHours': totalEstimatedHours,
      'estimatedCost': estimatedCost,
      'componentsUsed': componentsUsed,
      'steps': steps.map((step) => step.toJson()).toList(),
      'category': category,
      'sustainabilityScore': sustainabilityScore,
      'environmentalImpact': environmentalImpact,
    };
  }
}

class UpcycleStepsService {
  static List<UpcycleProject> generateDetailedUpcycleProjects(
    DiagnosisResult diagnosisResult,
  ) {
    final deviceSpec = diagnosisResult.deviceSpecifications;
    final deviceHealth = diagnosisResult.deviceHealth;
    final deviceModel = diagnosisResult.deviceModel;

    final projects = <UpcycleProject>[];

    // Generate projects based on device condition and specifications
    if (_isScreenGood(deviceHealth)) {
      projects.add(_createDigitalPhotoFrameProject(deviceModel, deviceSpec));
    }

    if (_isHardwareGood(deviceHealth)) {
      projects.add(_createSmartHomeDashboard(deviceModel, deviceSpec));

      if (_isScreenGood(deviceHealth)) {
        projects.add(_createRetroGameEmulator(deviceModel, deviceSpec));
      }
    }

    // Always include component salvage project
    projects.add(_createComponentSalvageProject(deviceModel, deviceSpec));

    // Add security camera project if camera is functional
    if (!deviceHealth.identifiedIssues.any((issue) =>
        issue.toLowerCase().contains('camera'))) {
      projects.add(_createSecurityCameraProject(deviceModel, deviceSpec));
    }

    return projects;
  }

  static bool _isScreenGood(DeviceHealth health) {
    return health.screenCondition == ScreenCondition.excellent ||
           health.screenCondition == ScreenCondition.good;
  }

  static bool _isHardwareGood(DeviceHealth health) {
    return health.hardwareCondition == HardwareCondition.excellent ||
           health.hardwareCondition == HardwareCondition.good;
  }

  static UpcycleProject _createDigitalPhotoFrameProject(
    String deviceModel,
    DeviceSpecification? specs,
  ) {
    return UpcycleProject(
      id: 'photo_frame_$deviceModel',
      title: 'Smart Digital Photo Frame',
      description: 'Transform your old device into a beautiful digital photo frame with slideshow capabilities and remote control via smartphone app.',
      deviceModel: deviceModel,
      difficulty: 'Easy',
      totalEstimatedHours: 3,
      estimatedCost: 300.0,
      componentsUsed: [
        'Original Display Screen',
        'Main Circuit Board',
        'Power Management Unit',
        'Wi-Fi Module',
        'Speaker (optional)',
      ],
      category: 'Home Decor',
      sustainabilityScore: 8.5,
      environmentalImpact: 'High Positive - Extends device life by 5+ years',
      steps: [
        UpcycleStep(
          stepNumber: 1,
          title: 'Device Disassembly and Assessment',
          description: 'Carefully disassemble the device to access the main components. Document the layout and take photos for reference during reassembly.',
          materials: ['Static-free workspace mat', 'Component storage containers', 'Labels'],
          tools: ['Phillips screwdriver set', 'Plastic spudger tools', 'Tweezers', 'Magnifying glass'],
          estimatedMinutes: 45,
          difficulty: 'Easy',
          safetyNote: 'Always power off the device and remove battery before disassembly. Wear anti-static wrist strap.',
          tips: [
            'Take photos at each step for easy reassembly',
            'Keep screws organized by size and location',
            'Handle components gently to avoid damage',
          ],
        ),
        UpcycleStep(
          stepNumber: 2,
          title: 'Screen and Main Board Extraction',
          description: 'Remove the display screen and main circuit board while preserving their connections. Test functionality before proceeding.',
          materials: ['Isopropyl alcohol', 'Cotton swabs', 'Thermal paste (if needed)'],
          tools: ['Fine-tip screwdrivers', 'Connector removal tools', 'Digital multimeter'],
          estimatedMinutes: 60,
          difficulty: 'Medium',
          safetyNote: 'Be extremely careful with ribbon cables - they tear easily. Check for shorts with multimeter.',
          tips: [
            'Clean all connectors with isopropyl alcohol',
            'Test screen functionality before frame construction',
            'Mark cable orientations with tape',
          ],
        ),
        UpcycleStep(
          stepNumber: 3,
          title: 'Custom Frame Construction',
          description: 'Build or modify a picture frame to house the screen and electronics. Ensure proper ventilation and access to ports.',
          materials: ['Wooden frame or 3D printed case', 'Mounting brackets', 'Ventilation grilles', 'Foam padding'],
          tools: ['Drill with bits', 'Jigsaw or router', 'Sandpaper', 'Wood stain/paint'],
          estimatedMinutes: 90,
          difficulty: 'Medium',
          safetyNote: 'Wear safety glasses when cutting or drilling. Ensure adequate ventilation for electronics.',
          tips: [
            'Design frame with easy access to SD card slot',
            'Include ventilation holes to prevent overheating',
            'Consider wall mounting options',
          ],
        ),
        UpcycleStep(
          stepNumber: 4,
          title: 'Power System Modification',
          description: 'Modify the power system for continuous operation. Install appropriate power supply and backup options.',
          materials: ['DC power adapter', 'Power management circuit', 'Backup battery (optional)'],
          tools: ['Soldering iron', 'Wire strippers', 'Heat shrink tubing', 'Voltage regulator'],
          estimatedMinutes: 75,
          difficulty: 'Hard',
          safetyNote: 'Work with power disconnected. Double-check voltage levels before connecting.',
          tips: [
            'Use original charging specifications',
            'Include power LED indicator',
            'Add fuse protection for safety',
          ],
        ),
        UpcycleStep(
          stepNumber: 5,
          title: 'Software Configuration and Setup',
          description: 'Install photo frame software or configure existing OS for slideshow mode. Set up remote control capabilities.',
          materials: ['MicroSD card', 'Photo management software', 'Network configuration'],
          tools: ['Computer for software setup', 'USB cable', 'Network scanner app'],
          estimatedMinutes: 60,
          difficulty: 'Easy',
          safetyNote: 'Only install software from trusted sources to prevent security issues.',
          tips: [
            'Configure automatic photo rotation',
            'Set up cloud synchronization for easy photo updates',
            'Create user-friendly remote control interface',
          ],
        ),
        UpcycleStep(
          stepNumber: 6,
          title: 'Final Assembly and Testing',
          description: 'Assemble all components into the frame, perform comprehensive testing, and apply finishing touches.',
          materials: ['Cable management ties', 'Protective case coating', 'User manual materials'],
          tools: ['Final assembly tools', 'Testing equipment', 'Photo samples for testing'],
          estimatedMinutes: 45,
          difficulty: 'Easy',
          safetyNote: 'Test all functions before final assembly. Ensure no loose connections.',
          tips: [
            'Create comprehensive testing checklist',
            'Document any troubleshooting steps',
            'Prepare user guide for family members',
          ],
        ),
      ],
    );
  }

  static UpcycleProject _createSmartHomeDashboard(
    String deviceModel,
    DeviceSpecification? specs,
  ) {
    return UpcycleProject(
      id: 'home_dashboard_$deviceModel',
      title: 'Smart Home Control Dashboard',
      description: 'Create a central control hub for your smart home devices with weather display, calendar integration, and device control.',
      deviceModel: deviceModel,
      difficulty: 'Hard',
      totalEstimatedHours: 6,
      estimatedCost: 800.0,
      componentsUsed: [
        'Main Circuit Board',
        'Touchscreen Display',
        'Wi-Fi Module',
        'Speakers',
        'Microphone (for voice control)',
        'Sensors (temperature, humidity)',
      ],
      category: 'Smart Home',
      sustainabilityScore: 9.0,
      environmentalImpact: 'Very High Positive - Central hub reduces need for multiple devices',
      steps: [
        UpcycleStep(
          stepNumber: 1,
          title: 'Hardware Assessment and Planning',
          description: 'Evaluate device capabilities and plan the smart home integration architecture.',
          materials: ['Network mapping tools', 'Smart home device inventory'],
          tools: ['Network analyzer', 'Specification sheets', 'Planning software'],
          estimatedMinutes: 60,
          difficulty: 'Medium',
          safetyNote: 'Document all existing smart home devices and their protocols.',
          tips: [
            'Map your existing smart home ecosystem',
            'Plan for future device additions',
            'Consider voice assistant integration',
          ],
        ),
        // Additional detailed steps would continue here...
      ],
    );
  }

  static UpcycleProject _createRetroGameEmulator(
    String deviceModel,
    DeviceSpecification? specs,
  ) {
    return UpcycleProject(
      id: 'retro_gaming_$deviceModel',
      title: 'Portable Retro Gaming Console',
      description: 'Convert your device into a portable retro gaming console with emulation software and custom controls.',
      deviceModel: deviceModel,
      difficulty: 'Hard',
      totalEstimatedHours: 8,
      estimatedCost: 1200.0,
      componentsUsed: [
        'Main Processor',
        'Display Screen',
        'Battery System',
        'Audio Components',
        'External Game Controls',
        'Storage Module',
      ],
      category: 'Gaming',
      sustainabilityScore: 8.0,
      environmentalImpact: 'Positive - Reduces need for new gaming hardware',
      steps: [
        UpcycleStep(
          stepNumber: 1,
          title: 'Performance Assessment and Game Console Planning',
          description: 'Test device performance capabilities and plan which gaming systems can be emulated effectively.',
          materials: ['Benchmark software', 'Emulation compatibility lists'],
          tools: ['Performance testing apps', 'Technical specifications'],
          estimatedMinutes: 90,
          difficulty: 'Medium',
          safetyNote: 'Ensure device can handle sustained gaming loads without overheating.',
          tips: [
            'Focus on consoles your device can handle smoothly',
            'Consider which game libraries you want to access',
            'Plan for external controller integration',
          ],
        ),
        // Additional detailed steps would continue here...
      ],
    );
  }

  static UpcycleProject _createComponentSalvageProject(
    String deviceModel,
    DeviceSpecification? specs,
  ) {
    return UpcycleProject(
      id: 'component_salvage_$deviceModel',
      title: 'Professional Component Harvesting',
      description: 'Systematically harvest valuable components for future electronics projects and repairs.',
      deviceModel: deviceModel,
      difficulty: 'Medium',
      totalEstimatedHours: 4,
      estimatedCost: 200.0,
      componentsUsed: [
        'All Internal Components',
        'Precious Metal Contacts',
        'Rare Earth Elements',
        'Reusable Circuits',
        'Mechanical Parts',
      ],
      category: 'Component Recovery',
      sustainabilityScore: 9.5,
      environmentalImpact: 'Maximum Positive - Prevents toxic waste, recovers valuable materials',
      steps: [
        UpcycleStep(
          stepNumber: 1,
          title: 'Component Identification and Value Assessment',
          description: 'Identify all valuable components and assess their reuse potential for future projects.',
          materials: ['Component database reference', 'Value estimation guides'],
          tools: ['Magnifying glass', 'Component identification app', 'Digital caliper'],
          estimatedMinutes: 45,
          difficulty: 'Easy',
          safetyNote: 'Some components may contain hazardous materials - research before handling.',
          tips: [
            'Focus on high-value components first',
            'Document component specifications',
            'Create inventory system for storage',
          ],
        ),
        UpcycleStep(
          stepNumber: 2,
          title: 'Systematic Disassembly and Component Extraction',
          description: 'Carefully remove components while preserving their functionality for future use.',
          materials: ['Anti-static bags', 'Component storage boxes', 'Labels'],
          tools: ['Precision screwdrivers', 'Desoldering station', 'Component puller'],
          estimatedMinutes: 120,
          difficulty: 'Medium',
          safetyNote: 'Use proper desoldering techniques to avoid component damage.',
          tips: [
            'Heat components gradually to avoid thermal shock',
            'Save all screws and small parts',
            'Test components before storage',
          ],
        ),
        UpcycleStep(
          stepNumber: 3,
          title: 'Component Testing and Categorization',
          description: 'Test all extracted components and organize them for efficient future use.',
          materials: ['Testing circuits', 'Storage system', 'Documentation materials'],
          tools: ['Multimeter', 'Component tester', 'Labeling system'],
          estimatedMinutes: 90,
          difficulty: 'Medium',
          safetyNote: 'Test components within their rated specifications to avoid damage.',
          tips: [
            'Create detailed component database',
            'Group similar components together',
            'Note any special handling requirements',
          ],
        ),
        UpcycleStep(
          stepNumber: 4,
          title: 'Precious Metal and Rare Earth Recovery',
          description: 'Identify and safely recover valuable metals and rare earth elements for specialized recycling.',
          materials: ['Chemical safety equipment', 'Recovery containers'],
          tools: ['Metal detection equipment', 'Safety gear', 'Specialized extraction tools'],
          estimatedMinutes: 60,
          difficulty: 'Hard',
          safetyNote: 'This step requires specialized knowledge and safety equipment - consider professional services.',
          tips: [
            'Research local precious metal recovery services',
            'Separate different metal types',
            'Document recovery for environmental impact tracking',
          ],
        ),
      ],
    );
  }

  static UpcycleProject _createSecurityCameraProject(
    String deviceModel,
    DeviceSpecification? specs,
  ) {
    return UpcycleProject(
      id: 'security_camera_$deviceModel',
      title: 'Smart Security Camera System',
      description: 'Transform your device into a smart security camera with motion detection, night vision, and remote monitoring.',
      deviceModel: deviceModel,
      difficulty: 'Medium',
      totalEstimatedHours: 5,
      estimatedCost: 600.0,
      componentsUsed: [
        'Camera Module',
        'Main Processor',
        'Wi-Fi Module',
        'Storage System',
        'Power Management',
        'Motion Sensors',
      ],
      category: 'Security',
      sustainabilityScore: 8.5,
      environmentalImpact: 'High Positive - Replaces need for new security hardware',
      steps: [
        UpcycleStep(
          stepNumber: 1,
          title: 'Camera System Analysis and Enhancement Planning',
          description: 'Evaluate camera capabilities and plan security system features.',
          materials: ['Camera testing charts', 'Light measurement tools'],
          tools: ['Camera testing software', 'Light meter', 'Image quality analyzer'],
          estimatedMinutes: 60,
          difficulty: 'Medium',
          safetyNote: 'Test camera in various lighting conditions to understand limitations.',
          tips: [
            'Document camera specifications and limits',
            'Plan optimal mounting locations',
            'Consider weatherproofing requirements',
          ],
        ),
        // Additional detailed steps would continue here...
      ],
    );
  }
}