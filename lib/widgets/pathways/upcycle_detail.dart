import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/device_diagnosis.dart';
import '../../providers/upcycling_provider.dart';
import '../../services/upcycle_steps_service.dart';

// Removed local UpcycleProject class - using the one from upcycle_steps_service.dart

class UpcycleDetail extends StatelessWidget {
  final DiagnosisResult diagnosisResult;

  const UpcycleDetail({super.key, required this.diagnosisResult});

  @override
  Widget build(BuildContext context) {
    return Consumer<UpcyclingProvider>(
      builder: (context, upcyclingProvider, child) {
        final suggestions = UpcycleStepsService.generateDetailedUpcycleProjects(diagnosisResult);

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
                  (project) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_getProjectIcon(project.category),
                                 size: 20, color: Colors.purple[600]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                project.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(project.difficulty),
                              backgroundColor: _getDifficultyColor(project.difficulty),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.description,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(LucideIcons.clock, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${project.totalEstimatedHours}h',
                              style: TextStyle(color: Colors.grey[600], fontSize: 11),
                            ),
                            const SizedBox(width: 16),
                            Icon(LucideIcons.dollarSign, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '₱${project.estimatedCost.toStringAsFixed(0)}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 11),
                            ),
                            const SizedBox(width: 16),
                            Icon(LucideIcons.leaf, size: 14, color: Colors.green[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${project.sustainabilityScore}/10',
                              style: TextStyle(color: Colors.green[600], fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${project.steps.length} detailed steps',
                                style: TextStyle(
                                  color: Colors.purple[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showProjectDetails(context, project),
                              child: Text(
                                'View Details →',
                                style: TextStyle(
                                  color: Colors.purple[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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

  IconData _getProjectIcon(String category) {
    switch (category.toLowerCase()) {
      case 'home decor':
        return LucideIcons.image;
      case 'smart home':
        return LucideIcons.house;
      case 'gaming':
        return LucideIcons.gamepad2;
      case 'security':
        return LucideIcons.camera;
      case 'component recovery':
        return LucideIcons.wrench;
      default:
        return LucideIcons.cpu;
    }
  }

  void _showProjectDetails(BuildContext context, UpcycleProject project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        Icon(_getProjectIcon(project.category),
                             size: 24, color: Colors.purple[600]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            project.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(project.difficulty),
                          backgroundColor: _getDifficultyColor(project.difficulty),
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      project.description,
                      style: TextStyle(color: Colors.grey[700], fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildProjectInfoCard(
                          'Duration',
                          '${project.totalEstimatedHours}h',
                          LucideIcons.clock,
                          Colors.blue
                        ),
                        const SizedBox(width: 12),
                        _buildProjectInfoCard(
                          'Cost',
                          '₱${project.estimatedCost.toStringAsFixed(0)}',
                          LucideIcons.dollarSign,
                          Colors.orange
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildProjectInfoCard(
                          'Sustainability',
                          '${project.sustainabilityScore}/10',
                          LucideIcons.leaf,
                          Colors.green
                        ),
                        const SizedBox(width: 12),
                        _buildProjectInfoCard(
                          'Steps',
                          '${project.steps.length}',
                          LucideIcons.list,
                          Colors.purple
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Project Steps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...project.steps.map((step) => _buildStepCard(step)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectInfoCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(UpcycleStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: Text(
            '${step.stepNumber}',
            style: TextStyle(
              color: Colors.purple[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          step.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '~${step.estimatedMinutes} min • ${step.difficulty}',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.description),
                if (step.materials.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Materials:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...step.materials.map((material) => Text('• $material')),
                ],
                if (step.tools.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Tools:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...step.tools.map((tool) => Text('• $tool')),
                ],
                if (step.safetyNote.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.triangleAlert,
                             color: Colors.orange[700], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            step.safetyNote,
                            style: TextStyle(color: Colors.orange[700], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (step.tips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Pro Tips:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...step.tips.map((tip) => Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(LucideIcons.lightbulb,
                             color: Colors.yellow[700], size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
