import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../models/device_diagnosis.dart';

class UpcycleProject {
  final String title;
  final String description;
  final IconData icon;
  final List<String> requiredComponents;
  final String difficulty;

  UpcycleProject({
    required this.title,
    required this.description,
    required this.icon,
    this.requiredComponents = const [],
    required this.difficulty,
  });
}

class UpcycleDetail extends StatelessWidget {
  final DiagnosisResult diagnosisResult;

  const UpcycleDetail({super.key, required this.diagnosisResult});

  @override
  Widget build(BuildContext context) {
    final suggestions = _buildUpcycleSuggestions(diagnosisResult);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Upcycle Ideas"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final project = suggestions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(project.icon, size: 24, color: Colors.blue.shade600),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        label: Text(project.difficulty),
                        backgroundColor: _getDifficultyColor(project.difficulty),
                        labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    project.description,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                  if (project.requiredComponents.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "Potentially useful components:",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: project.requiredComponents
                          .map((c) => Chip(label: Text(c)))
                          .toList(),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  List<UpcycleProject> _buildUpcycleSuggestions(DiagnosisResult result) {
    final projects = _getAllProjects();
    final Set<UpcycleProject> suggestions = {};

    // --- Decision-Making Logic ---

    final bool goodScreen = result.deviceHealth.screenCondition == ScreenCondition.excellent ||
        result.deviceHealth.screenCondition == ScreenCondition.good;

    final bool goodHardware =
        result.deviceHealth.hardwareCondition == HardwareCondition.excellent ||
            result.deviceHealth.hardwareCondition == HardwareCondition.good;

    final bool poorBattery = result.deviceHealth.batteryHealth < 0.5;

    // Rule 1: Screen-based projects
    if (goodScreen) {
      _addProject(suggestions, projects, "Digital Photo Frame");
    }

    // Rule 2: High-performance projects
    if (goodHardware) {
      _addProject(suggestions, projects, "Smart Home Hub");
      if (goodScreen) {
        _addProject(suggestions, projects, "Retro Game Emulator");
      }
    }

    // Rule 3: Component-based projects
    bool cameraIsOK = !result.deviceHealth.identifiedIssues
        .any((issue) => issue.toLowerCase().contains('camera'));

    if (cameraIsOK) {
      _addProject(suggestions, projects, "Security Camera");
    }

    if (!poorBattery) {
        _addProject(suggestions, projects, "Portable Bluetooth Speaker");
    }


    // Add a fallback project if no specific suggestions are generated
    if (suggestions.isEmpty) {
      _addProject(suggestions, projects, "Component Practice");
    }

    return suggestions.toList();
  }

  void _addProject(Set<UpcycleProject> suggestions, List<UpcycleProject> projects, String title) {
    for (final p in projects) {
      if (p.title == title) {
        suggestions.add(p);
        return; // Found it, no need to look further
      }
    }
  }

  List<UpcycleProject> _getAllProjects() {
    return [
      UpcycleProject(
        title: "Smart Home Hub",
        description:
            "Use the mainboard and screen to create a central dashboard for controlling smart home devices.",
        icon: LucideIcons.house,
        difficulty: "Hard",
        requiredComponents: ["Mainboard", "Screen", "Wi-Fi Module"],
      ),
      UpcycleProject(
        title: "Digital Photo Frame",
        description:
            "A classic project. If the screen is in good condition, it can display a slideshow of your favorite photos.",
        icon: LucideIcons.image,
        difficulty: "Easy",
        requiredComponents: ["Screen", "Mainboard"],
      ),
      UpcycleProject(
        title: "Portable Bluetooth Speaker",
        description:
            "Salvage the speakers and battery to create a portable music player. Requires some soldering and a Bluetooth audio module.",
        icon: LucideIcons.volume2,
        difficulty: "Medium",
        requiredComponents: ["Speakers", "Battery", "Charging Port"],
      ),
      UpcycleProject(
        title: "Security Camera",
        description:
            "If the camera module still works, you can set it up as a DIY security camera, streaming video over your local network.",
        icon: LucideIcons.camera,
        difficulty: "Medium",
        requiredComponents: ["Camera Module", "Mainboard", "Wi-Fi Module"],
      ),
      UpcycleProject(
        title: "Retro Game Emulator",
        description:
            "The processor might be powerful enough to emulate old game consoles. A fun project for gamers.",
        icon: LucideIcons.gamepad2,
        difficulty: "Hard",
        requiredComponents: ["Mainboard", "Screen", "Buttons (optional)"],
      ),
      UpcycleProject(
        title: "Component Practice",
        description:
            "Carefully disassemble the device to learn how it was constructed. A great way to practice soldering and identify components for future projects.",
        icon: LucideIcons.wrench,
        difficulty: "Easy",
        requiredComponents: ["All components"],
      ),
    ];
  }
}
