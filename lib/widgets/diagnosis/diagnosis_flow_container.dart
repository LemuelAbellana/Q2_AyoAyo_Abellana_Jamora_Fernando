import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/models/pathway.dart';
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
  DiagnosisState _currentState = DiagnosisState.form;
  Pathway _selectedPathway = Pathway.none;

  void _startDiagnosis() {
    setState(() => _currentState = DiagnosisState.results);
  }

  void _selectPathway(Pathway pathway) {
    setState(() => _selectedPathway = pathway);
  }

  Widget _buildCurrentStateWidget() {
    return Consumer<DiagnosisProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingIndicator();
        } else if (provider.currentResult != null) {
          return ResultsView(
            selectedPathway: _selectedPathway,
            onPathwaySelected: _selectPathway,
          );
        } else {
          return DiagnosisForm(onDiagnose: _startDiagnosis);
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
