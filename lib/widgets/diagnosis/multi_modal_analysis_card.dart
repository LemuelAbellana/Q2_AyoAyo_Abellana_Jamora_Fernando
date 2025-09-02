import 'package:flutter/material.dart';
import 'package:ayoayo/models/device_diagnosis.dart';

class MultiModalAnalysisCard extends StatelessWidget {
  final DiagnosisResult diagnosisResult;
  final bool hasImages;
  final bool hasUserDescription;

  const MultiModalAnalysisCard({
    super.key,
    required this.diagnosisResult,
    required this.hasImages,
    required this.hasUserDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildAnalysisSourcesIndicator(context),
            const SizedBox(height: 16),
            _buildAccuracyIndicator(context),
            const SizedBox(height: 16),
            _buildCorrelationInsights(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade600, Colors.blue.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Multi-Modal AI Analysis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              Text(
                'Visual + Textual Intelligence',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getConfidenceColor(diagnosisResult.confidenceScore),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${(diagnosisResult.confidenceScore * 100).toInt()}% Confidence',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisSourcesIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Sources Analyzed',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSourceIndicator(
                  'Visual Analysis',
                  hasImages,
                  Icons.camera_alt,
                  hasImages
                      ? 'Device images processed with AI computer vision'
                      : 'No images provided for analysis',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSourceIndicator(
                  'User Description',
                  hasUserDescription,
                  Icons.description,
                  hasUserDescription
                      ? 'User-reported symptoms and issues analyzed'
                      : 'No additional information provided',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSourceIndicator(
    String title,
    bool isAvailable,
    IconData icon,
    String description,
  ) {
    final color = isAvailable ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(fontSize: 10, color: color.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyIndicator(BuildContext context) {
    final accuracyLevel = _getAccuracyLevel(diagnosisResult.confidenceScore);
    final accuracyColor = _getConfidenceColor(diagnosisResult.confidenceScore);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accuracyColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accuracyColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getAccuracyIcon(diagnosisResult.confidenceScore),
            color: accuracyColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Accuracy: $accuracyLevel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: accuracyColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  _getAccuracyDescription(diagnosisResult.confidenceScore),
                  style: TextStyle(
                    fontSize: 12,
                    color: accuracyColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrelationInsights(BuildContext context) {
    final insights = _generateCorrelationInsights();

    if (insights.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis Insights',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.indigo.shade800,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => _buildInsightItem(insight)),
      ],
    );
  }

  Widget _buildInsightItem(String insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.indigo.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              insight,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green.shade600;
    if (confidence >= 0.6) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  IconData _getAccuracyIcon(double confidence) {
    if (confidence >= 0.8) return Icons.verified;
    if (confidence >= 0.6) return Icons.info;
    return Icons.warning;
  }

  String _getAccuracyLevel(double confidence) {
    if (confidence >= 0.9) return 'Excellent';
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.7) return 'Good';
    if (confidence >= 0.6) return 'Moderate';
    return 'Limited';
  }

  String _getAccuracyDescription(double confidence) {
    if (confidence >= 0.9) {
      return 'Multiple data sources provide strong validation';
    }
    if (confidence >= 0.8) {
      return 'Good correlation between visual and textual evidence';
    }
    if (confidence >= 0.7) {
      return 'Solid analysis with adequate supporting data';
    }
    if (confidence >= 0.6) {
      return 'Reasonable assessment with some data limitations';
    }
    return 'Limited data available - assessment may be incomplete';
  }

  List<String> _generateCorrelationInsights() {
    final insights = <String>[];

    if (hasImages && hasUserDescription) {
      insights.add(
        'Cross-validation performed between visual evidence and user reports',
      );

      // Check for issues mentioned in diagnosis
      final issueCount = diagnosisResult.deviceHealth.identifiedIssues.length;
      if (issueCount > 3) {
        insights.add(
          'Multiple issues identified across different analysis methods',
        );
      } else if (issueCount > 0) {
        insights.add('Consistent findings across visual and textual analysis');
      }

      // Check confidence level
      if (diagnosisResult.confidenceScore > 0.8) {
        insights.add(
          'High correlation between different data sources increases reliability',
        );
      }
    } else if (hasImages) {
      insights.add(
        'Analysis based primarily on visual evidence from uploaded images',
      );
      insights.add('Consider providing device symptoms for enhanced accuracy');
    } else if (hasUserDescription) {
      insights.add(
        'Analysis based on user-reported information and device specifications',
      );
      insights.add(
        'Upload device images for visual validation and improved accuracy',
      );
    }

    // Add market intelligence insight
    insights.add(
      'Market valuation incorporates both condition assessment and local demand patterns',
    );

    return insights;
  }
}
