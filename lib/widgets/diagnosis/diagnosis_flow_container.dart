import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/widgets/diagnosis/diagnosis_form.dart';
import '/widgets/diagnosis/loading_indicator.dart';
import '/widgets/diagnosis/results_view.dart';
import '/providers/diagnosis_provider.dart';

enum DiagnosisState { form, loading, results }

class DiagnosisFlowContainer extends StatefulWidget {
  final GlobalKey diagnoseKey;
  const DiagnosisFlowContainer({required this.diagnoseKey, super.key});

  @override
  State<DiagnosisFlowContainer> createState() => _DiagnosisFlowContainerState();
}

class _DiagnosisFlowContainerState extends State<DiagnosisFlowContainer> {
  Widget _buildCurrentStateWidget() {
    return Consumer<DiagnosisProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingIndicator();
        } else if (provider.currentResult != null) {
          return const ResultsView(); // Removed selectedPathway and onPathwaySelected
        } else {
          return const DiagnosisForm(); // Removed onDiagnose
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: widget.diagnoseKey,
      padding: const EdgeInsets.all(16.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStateWidget(),
      ),
    );
  }
}
