import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/device_diagnosis.dart';
import '../../providers/upcycling_provider.dart';

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
    return Consumer<UpcyclingProvider>(
      builder: (context, upcyclingProvider, child) {
        final suggestions = _buildUpcycleSuggestions(diagnosisResult);

        return Card(
          color: Colors.grey[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "Upcycle Your Device",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDeviceSummary(),
                const SizedBox(height: 16),
                _buildAISuggestions(context, suggestions),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(LucideIcons.palette),
                        label: const Text('Upcycle Studio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/upcycle');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(LucideIcons.wand),
                        label: const Text('AI Ideas'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[700]!),
                        ),
                        onPressed: () => _showAIProjectDialog(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildQuickStats(upcyclingProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.cpu, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Device Assessment",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildConditionRow(
            "Screen Condition",
            diagnosisResult.deviceHealth.screenCondition.name,
            _getConditionColor(diagnosisResult.deviceHealth.screenCondition),
          ),
          _buildConditionRow(
            "Battery Health",
            "${diagnosisResult.deviceHealth.batteryHealth.toStringAsFixed(0)}%",
            _getBatteryColor(diagnosisResult.deviceHealth.batteryHealth),
          ),
          _buildConditionRow(
            "Hardware Condition",
            diagnosisResult.deviceHealth.hardwareCondition.name,
            _getHardwareColor(diagnosisResult.deviceHealth.hardwareCondition),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Potential Value:"),
              Text(
                "₱${diagnosisResult.valueEstimation.partsValue.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAISuggestions(
    BuildContext context,
    List<UpcycleProject> suggestions,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.brain, color: Colors.purple[700]),
              const SizedBox(width: 8),
              Text(
                "AI-Suggested Projects",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (suggestions.isNotEmpty) ...[
            ...suggestions
                .take(2)
                .map(
                  (project) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(project.icon, size: 20, color: Colors.purple[600]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            project.title,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        Chip(
                          label: Text(project.difficulty),
                          backgroundColor: _getDifficultyColor(
                            project.difficulty,
                          ),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            if (suggestions.length > 2)
              Text(
                "+ ${suggestions.length - 2} more ideas available",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.purple[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ] else ...[
            const Text(
              "AI analysis in progress...",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats(UpcyclingProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          "Projects",
          "${provider.userProjects.length}",
          Colors.grey,
        ),
        _buildStatItem(
          "Completed",
          "${provider.completedProjects.length}",
          Colors.green,
        ),
        _buildStatItem("Materials", "50+", Colors.blue),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildConditionRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAIProjectDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Project Generator'),
        content: const Text(
          'Generate personalized upcycling project ideas based on your device\'s condition and components.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Navigate to upcycle screen to see AI-generated ideas
              Navigator.pushNamed(context, '/upcycle');
            },
            child: const Text('Generate Ideas'),
          ),
        ],
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

  Color _getConditionColor(ScreenCondition condition) {
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
        return Colors.grey;
    }
  }

  Color _getBatteryColor(double batteryHealth) {
    if (batteryHealth > 0.8) return Colors.green;
    if (batteryHealth > 0.5) return Colors.orange;
    return Colors.red;
  }

  Color _getHardwareColor(HardwareCondition condition) {
    switch (condition) {
      case HardwareCondition.excellent:
      case HardwareCondition.good:
        return Colors.green;
      case HardwareCondition.fair:
        return Colors.orange;
      case HardwareCondition.poor:
      case HardwareCondition.damaged:
        return Colors.red;
      case HardwareCondition.unknown:
        return Colors.grey;
    }
  }

  List<UpcycleProject> _buildUpcycleSuggestions(DiagnosisResult result) {
    final projects = _getAllProjects();
    final Set<UpcycleProject> suggestions = {};

    // --- Decision-Making Logic ---

    final bool goodScreen =
        result.deviceHealth.screenCondition == ScreenCondition.excellent ||
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
    bool cameraIsOK = !result.deviceHealth.identifiedIssues.any(
      (issue) => issue.toLowerCase().contains('camera'),
    );

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

  void _addProject(
    Set<UpcycleProject> suggestions,
    List<UpcycleProject> projects,
    String title,
  ) {
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
