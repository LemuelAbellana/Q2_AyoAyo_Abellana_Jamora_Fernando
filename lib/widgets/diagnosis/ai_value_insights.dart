import 'package:flutter/material.dart';
import 'package:ayoayo/services/ai_value_engine.dart';
import 'package:ayoayo/models/device_diagnosis.dart';

class AIValueInsights extends StatelessWidget {
  final DiagnosisResult diagnosisResult;

  const AIValueInsights({super.key, required this.diagnosisResult});

  @override
  Widget build(BuildContext context) {
    final valueAnalysis = AIValueEngine.analyzeDeviceValue(
      diagnosisResult.deviceModel,
      diagnosisResult.deviceHealth,
    );

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, valueAnalysis),
            const SizedBox(height: 20),
            _buildCurrentValue(context, valueAnalysis),
            const SizedBox(height: 24),
            _buildMarketAnalysis(context, valueAnalysis),
            const SizedBox(height: 24),
            _buildRepairScenarios(context, valueAnalysis),
            const SizedBox(height: 24),
            _buildInvestmentRecommendations(context, valueAnalysis),
            const SizedBox(height: 20),
            _buildConfidenceIndicator(context, valueAnalysis),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ValueAnalysis analysis) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade600, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.analytics_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Value Engine Analysis',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Text(
                'Powered by RAG AI • ${_formatDateTime(analysis.analysisTimestamp)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentValue(BuildContext context, ValueAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Market Value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₱${diagnosisResult.valueEstimation.currentValue.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on current condition and Davao market rates',
            style: TextStyle(color: Colors.green.shade600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketAnalysis(BuildContext context, ValueAnalysis analysis) {
    final market = analysis.marketAnalysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Market Intelligence',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildMarketMetric(
                'Current Value',
                '₱${diagnosisResult.valueEstimation.currentValue.toStringAsFixed(0)}',
                Colors.green.shade600,
                Icons.monetization_on,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMarketMetric(
                'Market Velocity',
                '${(market.marketVelocity * 100).toInt()}%',
                _getVelocityColor(market.marketVelocity),
                Icons.speed,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMarketMetric(
                'Repair Cost',
                '₱${diagnosisResult.valueEstimation.repairCost.toStringAsFixed(0)}',
                Colors.orange.shade600,
                Icons.build,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMarketMetric(
                'Post-Repair Value',
                '₱${diagnosisResult.valueEstimation.postRepairValue.toStringAsFixed(0)}',
                Colors.blue.shade600,
                Icons.trending_up,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMarketMetric(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepairScenarios(BuildContext context, ValueAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repair Investment Scenarios',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 16),
        // Use diagnosis results with AI enhancement
        _buildDiagnosisBasedScenarios(context, diagnosisResult, analysis),
      ],
    );
  }

  Widget _buildDiagnosisBasedScenarios(
    BuildContext context,
    DiagnosisResult diagnosis,
    ValueAnalysis analysis,
  ) {
    return Column(
      children: [
        // Current condition scenario
        _buildRepairScenarioCard(
          context,
          RepairScenario(
            title: 'Current Condition',
            description: 'Device value in current condition',
            repairCost: 0,
            postRepairValue: diagnosis.valueEstimation.currentValue,
            roi: 0,
            timeToSell: '1-3 days',
            riskLevel: 'Low',
          ),
        ),
        // Post-repair scenario
        if (diagnosis.valueEstimation.repairCost > 0)
          _buildRepairScenarioCard(
            context,
            RepairScenario(
              title: 'After Professional Repair',
              description: 'Value after recommended repairs',
              repairCost: diagnosis.valueEstimation.repairCost,
              postRepairValue: diagnosis.valueEstimation.postRepairValue,
              roi:
                  ((diagnosis.valueEstimation.postRepairValue -
                      diagnosis.valueEstimation.currentValue -
                      diagnosis.valueEstimation.repairCost) /
                  diagnosis.valueEstimation.repairCost *
                  100),
              timeToSell: '3-5 days',
              riskLevel:
                  diagnosis.valueEstimation.postRepairValue >
                      diagnosis.valueEstimation.currentValue +
                          diagnosis.valueEstimation.repairCost
                  ? 'Low'
                  : 'Moderate',
            ),
          ),
        // Parts value scenario
        _buildRepairScenarioCard(
          context,
          RepairScenario(
            title: 'Parts & Components',
            description: 'Value if sold for parts/recycling',
            repairCost: 0,
            postRepairValue: diagnosis.valueEstimation.partsValue,
            roi: 0,
            timeToSell: '5-7 days',
            riskLevel: 'Moderate',
          ),
        ),
      ],
    );
  }

  Widget _buildRepairScenarioCard(
    BuildContext context,
    RepairScenario scenario,
  ) {
    final roiColor = scenario.roi > 50
        ? Colors.green
        : scenario.roi > 20
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: roiColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: roiColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  scenario.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: roiColor.shade700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roiColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${scenario.roi.toStringAsFixed(0)}% ROI',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            scenario.description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildScenarioDetail(
                'Cost',
                '₱${scenario.repairCost.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 16),
              _buildScenarioDetail(
                'Value',
                '₱${scenario.postRepairValue.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 16),
              _buildScenarioDetail('Time', scenario.timeToSell),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScenarioDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentRecommendations(
    BuildContext context,
    ValueAnalysis analysis,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Investment Recommendations',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        const SizedBox(height: 16),
        ...analysis.investmentRecommendations.map(
          (recommendation) => _buildRecommendationCard(context, recommendation),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    InvestmentRecommendation recommendation,
  ) {
    final color = _getRecommendationColor(recommendation.recommendation);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getRecommendationIcon(recommendation.recommendation),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  recommendation.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${(recommendation.confidence * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.description,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          if (recommendation.expectedROI > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Expected ROI: ${recommendation.expectedROI.toStringAsFixed(0)}% • Timeframe: ${recommendation.timeframe}',
              style: TextStyle(
                color: color.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator(
    BuildContext context,
    ValueAnalysis analysis,
  ) {
    final confidence = analysis.confidenceScore;
    final confidenceColor = confidence > 0.8
        ? Colors.green
        : confidence > 0.6
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: confidenceColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: confidenceColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.psychology, color: confidenceColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Confidence',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: confidenceColor.shade700,
                  ),
                ),
                Text(
                  '${(confidence * 100).toInt()}% confidence based on available data and market intelligence',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getVelocityColor(double velocity) {
    if (velocity > 0.8) return Colors.green.shade600;
    if (velocity > 0.6) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _getRecommendationColor(String recommendation) {
    switch (recommendation) {
      case 'REPAIR':
        return Colors.blue.shade600;
      case 'SELL_PREMIUM':
        return Colors.green.shade600;
      case 'SELL_LOCAL':
        return Colors.orange.shade600;
      case 'DONATE':
        return Colors.purple.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getRecommendationIcon(String recommendation) {
    switch (recommendation) {
      case 'REPAIR':
        return Icons.build;
      case 'SELL_PREMIUM':
        return Icons.star;
      case 'SELL_LOCAL':
        return Icons.store;
      case 'DONATE':
        return Icons.favorite;
      default:
        return Icons.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
