import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '/models/pathway.dart';
import '/models/device_diagnosis.dart';
import '/providers/diagnosis_provider.dart';
import '/widgets/pathways/donate_detail.dart';
import '/widgets/pathways/pathway_card.dart';
import '/widgets/pathways/repair_detail.dart';
import '/widgets/pathways/upcycle_detail.dart';
import '/widgets/pathways/resell_detail.dart';

class ResultsView extends StatelessWidget {
  const ResultsView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<DiagnosisProvider>(
          builder: (context, provider, child) {
            return _DevicePassportCard(provider: provider);
          },
        ),
        const SizedBox(height: 16),
        Consumer<DiagnosisProvider>(
          builder: (context, provider, child) {
            return _ValueEngineCard(provider: provider);
          },
        ),
        const SizedBox(height: 24),
        const Text(
          "2. Choose Your Pathway",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer<DiagnosisProvider>(
          builder: (context, provider, child) {
            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                PathwayCard(
                  label: 'Repair It',
                  icon: LucideIcons.wrench,
                  color: Colors.green,
                  isSelected: provider.selectedPathway == Pathway.repair,
                  onTap: () => provider.setSelectedPathway(Pathway.repair),
                ),
                PathwayCard(
                  label: 'Resell',
                  icon: LucideIcons.handshake,
                  color: Colors.blue,
                  isSelected: provider.selectedPathway == Pathway.resell,
                  onTap: () => provider.setSelectedPathway(Pathway.resell),
                ),
                PathwayCard(
                  label: 'Upcycle',
                  icon: LucideIcons.recycle,
                  color: Colors.grey,
                  isSelected: provider.selectedPathway == Pathway.upcycle,
                  onTap: () => provider.setSelectedPathway(Pathway.upcycle),
                ),
                PathwayCard(
                  label: 'Donate It',
                  icon: LucideIcons.heart,
                  color: Colors.pink,
                  isSelected: provider.selectedPathway == Pathway.donate,
                  onTap: () => provider.setSelectedPathway(Pathway.donate),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        // Display details based on selected pathway
        Consumer<DiagnosisProvider>(
          builder: (context, provider, child) {
            if (provider.currentResult == null) {
              return const SizedBox.shrink();
            }
            switch (provider.selectedPathway) {
              case Pathway.repair:
                return const RepairDetail();
              case Pathway.resell:
                return const ResellDetail();
              case Pathway.upcycle:
                return UpcycleDetail(diagnosisResult: provider.currentResult!);
              case Pathway.donate:
                return const DonateDetail();
              default:
                return const SizedBox.shrink();
            }
          },
        ),
        const SizedBox(height: 16),
        Consumer<DiagnosisProvider>(
          builder: (context, provider, child) {
            if (provider.currentResult?.aiAnalysis != null) {
              return _AIAnalysisCard(provider: provider);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _DevicePassportCard extends StatelessWidget {
  final DiagnosisProvider provider;
  const _DevicePassportCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  "Device Passport",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (provider.currentResult?.confidenceScore != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Confidence: ${(provider.currentResult!.confidenceScore * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(
                LucideIcons.batteryWarning,
                color: provider.getBatteryHealthColor(),
              ),
              title: const Text("Battery Health"),
              trailing: Text(
                provider.getFormattedBatteryHealth(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: provider.getBatteryHealthColor(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                LucideIcons.smartphone,
                color: provider.getScreenConditionColor(),
              ),
              title: const Text("Screen Condition"),
              trailing: Text(
                provider.getScreenConditionText(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: provider.getScreenConditionColor(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                LucideIcons.cpu,
                color: _getHardwareConditionColor(
                  provider.currentResult?.deviceHealth.hardwareCondition,
                ),
              ),
              title: const Text("Hardware"),
              trailing: Text(
                provider.getHardwareConditionText(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getHardwareConditionColor(
                    provider.currentResult?.deviceHealth.hardwareCondition,
                  ),
                ),
              ),
            ),
            if (provider.currentResult?.confidenceScore != null) ...[
              const Divider(),
              ListTile(
                leading: Icon(
                  LucideIcons.brain,
                  color: _getConfidenceColor(
                    provider.currentResult!.confidenceScore,
                  ),
                ),
                title: const Text("AI Confidence"),
                trailing: Text(
                  '${(provider.currentResult!.confidenceScore * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getConfidenceColor(
                      provider.currentResult!.confidenceScore,
                    ),
                  ),
                ),
              ),
            ],
            if (provider
                    .currentResult
                    ?.deviceHealth
                    .identifiedIssues
                    .isNotEmpty ==
                true) ...[
              const Divider(),
              const Text(
                "Identified Issues:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...provider.currentResult!.deviceHealth.identifiedIssues.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(issue)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ValueEngineCard extends StatelessWidget {
  final DiagnosisProvider provider;
  const _ValueEngineCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "AI-Powered Value Engine",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Current Value:"),
                Text(
                  provider.getFormattedCurrentValue(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Post-Repair Value:"),
                Text(
                  provider.getFormattedPostRepairValue(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Parts Value:"),
                Text(
                  provider.getFormattedPartsValue(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (provider.currentResult?.valueEstimation.repairCost != null) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Estimated Repair Cost:"),
                  Text(
                    "${provider.currentResult!.valueEstimation.currency}${provider.currentResult!.valueEstimation.repairCost.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AIAnalysisCard extends StatelessWidget {
  final DiagnosisProvider provider;
  const _AIAnalysisCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.brain, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  "AI Analysis & Recommendations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              provider.currentResult?.aiAnalysis ?? '',
              style: const TextStyle(height: 1.4),
            ),
            if (provider.currentResult?.recommendations.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              const Text(
                "Recommended Actions:",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...provider
                  .getSortedRecommendations()
                  .take(3)
                  .map(
                    (recommendation) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _getActionIcon(recommendation.type),
                                size: 16,
                                color: Colors.green[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  recommendation.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Priority: ${(recommendation.priority * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recommendation.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getActionIcon(ActionType type) {
    switch (type) {
      case ActionType.repair:
        return LucideIcons.wrench;
      case ActionType.replace:
        return LucideIcons.repeat;
      case ActionType.donate:
        return LucideIcons.heart;
      case ActionType.recycle:
        return LucideIcons.recycle;
      case ActionType.sell:
        return LucideIcons.dollarSign;
      case ActionType.other:
        return LucideIcons.info;
    }
  }
}

// Helper functions for enhanced Device Passport
Color _getHardwareConditionColor(HardwareCondition? condition) {
  switch (condition) {
    case HardwareCondition.excellent:
      return Colors.green;
    case HardwareCondition.good:
      return Colors.blue;
    case HardwareCondition.fair:
      return Colors.orange;
    case HardwareCondition.poor:
      return Colors.red;
    case HardwareCondition.damaged:
      return Colors.red.shade800;
    case HardwareCondition.unknown:
    case null:
      return Colors.grey;
  }
}

Color _getConfidenceColor(double confidence) {
  if (confidence >= 0.8) return Colors.green;
  if (confidence >= 0.6) return Colors.orange;
  return Colors.red;
}