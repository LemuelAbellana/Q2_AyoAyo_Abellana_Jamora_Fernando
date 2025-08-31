import 'package:flutter/material.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/widgets/diagnosis/recommendations_view.dart';
import 'package:ayoayo/widgets/diagnosis/ai_value_insights.dart';
import 'package:ayoayo/widgets/diagnosis/multi_modal_analysis_card.dart';

class DevicePassportScreen extends StatelessWidget {
  final DevicePassport passport;

  const DevicePassportScreen({super.key, required this.passport});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Passport')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              passport.buildPassport(context),
              const SizedBox(height: 16.0),

              // Multi-Modal Analysis Card
              MultiModalAnalysisCard(
                diagnosisResult: passport.lastDiagnosis,
                hasImages: passport.imageUrls.isNotEmpty,
                hasUserDescription:
                    passport.lastDiagnosis.aiAnalysis.contains('User') ||
                    passport.lastDiagnosis.aiAnalysis.contains('description'),
              ),

              // AI Value Engine Analysis
              AIValueInsights(diagnosisResult: passport.lastDiagnosis),

              const SizedBox(height: 16.0),
              Text(
                'AI Analysis',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8.0),
              Text(passport.lastDiagnosis.aiAnalysis),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confidence Score',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${(passport.lastDiagnosis.confidenceScore * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8.0),
              RecommendationsView(
                recommendations: passport.lastDiagnosis.recommendations,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
