import 'package:ayoayo/services/knowledge_base.dart';
import 'package:ayoayo/models/device_diagnosis.dart';

class AIValueEngine {
  // AI-powered device valuation with market intelligence
  
  static ValueAnalysis analyzeDeviceValue(String deviceModel, DeviceHealth deviceHealth) {
    final deviceData = KnowledgeBase.getDeviceData(deviceModel);
    final repairCosts = KnowledgeBase.getRepairCosts(deviceModel);
    
    // Enhanced market analysis
    final marketAnalysis = _analyzeMarketConditions(deviceModel, deviceData);
    
    // Calculate precise current value
    final currentValue = _calculateCurrentValue(deviceModel, deviceHealth, deviceData);
    
    // Calculate repair scenarios
    final repairScenarios = _calculateRepairScenarios(
      currentValue, 
      deviceHealth, 
      repairCosts,
      deviceData
    );
    
    // Generate investment recommendations
    final recommendations = _generateInvestmentRecommendations(
      currentValue,
      repairScenarios,
      marketAnalysis
    );
    
    // Calculate confidence score
    final confidence = _calculateAnalysisConfidence(deviceData, deviceHealth);
    
    return ValueAnalysis(
      currentMarketValue: currentValue,
      repairScenarios: repairScenarios,
      marketAnalysis: marketAnalysis,
      investmentRecommendations: recommendations,
      confidenceScore: confidence,
      analysisTimestamp: DateTime.now(),
    );
  }
  
  static double _calculateCurrentValue(
    String deviceModel, 
    DeviceHealth deviceHealth,
    Map<String, dynamic>? deviceData
  ) {
    final conditions = {
      'batteryHealth': deviceHealth.batteryHealth,
      'screenCondition': deviceHealth.screenCondition.toString().split('.').last,
      'hardwareCondition': deviceHealth.hardwareCondition.toString().split('.').last,
    };
    
    double value = KnowledgeBase.calculatePreciseValue(deviceModel, conditions);
    
    // Apply issue penalties
    for (final issue in deviceHealth.identifiedIssues) {
      if (issue.toLowerCase().contains('water') || issue.toLowerCase().contains('liquid')) {
        value *= 0.4; // Major water damage penalty
      } else if (issue.toLowerCase().contains('motherboard') || issue.toLowerCase().contains('logic')) {
        value *= 0.3; // Critical hardware penalty
      } else if (issue.toLowerCase().contains('crack') || issue.toLowerCase().contains('shatter')) {
        value *= 0.6; // Screen damage penalty
      } else {
        value *= 0.95; // Minor issue penalty
      }
    }
    
    return value;
  }
  
  static MarketAnalysis _analyzeMarketConditions(String deviceModel, Map<String, dynamic>? deviceData) {
    final currentMonth = DateTime.now().month;
    final marketData = KnowledgeBase.marketIntelligence['local_market'] as Map<String, dynamic>;
    final seasonalData = marketData['seasonalDemand'] as Map<String, dynamic>;
    
    // Determine current demand
    String demandLevel = 'moderate';
    final monthNames = ['', 'january', 'february', 'march', 'april', 'may', 'june',
                       'july', 'august', 'september', 'october', 'november', 'december'];
    final currentMonthName = monthNames[currentMonth];
    
    for (final level in seasonalData.keys) {
      final months = seasonalData[level] as List;
      if (months.contains(currentMonthName)) {
        demandLevel = level;
        break;
      }
    }
    
    // Market velocity (how quickly device sells)
    double marketVelocity = 0.7; // Base velocity
    if (deviceData != null) {
      final marketDemandStr = deviceData['marketDemand'] as String;
      switch (marketDemandStr) {
        case 'very_high':
          marketVelocity = 0.95;
          break;
        case 'high':
          marketVelocity = 0.85;
          break;
        case 'moderate':
          marketVelocity = 0.7;
          break;
        default:
          marketVelocity = 0.5;
      }
    }
    
    // Price stability prediction
    final priceStability = _predictPriceStability(deviceModel, deviceData);
    
    return MarketAnalysis(
      currentDemand: demandLevel,
      marketVelocity: marketVelocity,
      priceStability: priceStability,
      optimalSellTime: _calculateOptimalSellTime(demandLevel, priceStability),
      competitiveDevices: _getCompetitiveDevices(deviceModel),
    );
  }
  
  static List<RepairScenario> _calculateRepairScenarios(
    double currentValue,
    DeviceHealth deviceHealth,
    Map<String, double> repairCosts,
    Map<String, dynamic>? deviceData
  ) {
    final scenarios = <RepairScenario>[];
    
    // No repair scenario
    scenarios.add(RepairScenario(
      title: 'Sell As-Is',
      description: 'Sell device in current condition',
      repairCost: 0,
      postRepairValue: currentValue,
      roi: 0,
      timeToSell: '1-3 days',
      riskLevel: 'Low',
    ));
    
    // Screen repair scenario
    if (deviceHealth.screenCondition == ScreenCondition.cracked || 
        deviceHealth.screenCondition == ScreenCondition.poor) {
      final screenCost = repairCosts['screen'] ?? 3000;
      final postRepairValue = currentValue * 1.8; // Screen repair typically doubles value
      final roi = ((postRepairValue - currentValue - screenCost) / screenCost * 100);
      
      scenarios.add(RepairScenario(
        title: 'Screen Repair',
        description: 'Replace damaged screen to restore functionality',
        repairCost: screenCost,
        postRepairValue: postRepairValue,
        roi: roi,
        timeToSell: '3-5 days',
        riskLevel: roi > 50 ? 'Low' : 'Moderate',
      ));
    }
    
    // Battery replacement scenario
    if (deviceHealth.batteryHealth < 85) {
      final batteryCost = repairCosts['battery'] ?? 1500;
      final valueIncrease = (100 - deviceHealth.batteryHealth) / 100 * currentValue * 0.3;
      final postRepairValue = currentValue + valueIncrease;
      final roi = (valueIncrease - batteryCost) / batteryCost * 100;
      
      scenarios.add(RepairScenario(
        title: 'Battery Replacement',
        description: 'Replace battery to improve performance and longevity',
        repairCost: batteryCost,
        postRepairValue: postRepairValue,
        roi: roi,
        timeToSell: '2-4 days',
        riskLevel: roi > 30 ? 'Low' : 'Moderate',
      ));
    }
    
    // Comprehensive repair scenario
    if (scenarios.length > 2) {
      final totalCost = scenarios.skip(1).fold(0.0, (sum, scenario) => sum + scenario.repairCost);
      final totalValue = currentValue * 2.2; // Comprehensive repair premium
      final roi = ((totalValue - currentValue - totalCost) / totalCost * 100);
      
      scenarios.add(RepairScenario(
        title: 'Complete Restoration',
        description: 'Full device restoration for maximum value recovery',
        repairCost: totalCost,
        postRepairValue: totalValue,
        roi: roi,
        timeToSell: '5-7 days',
        riskLevel: roi > 40 ? 'Moderate' : 'High',
      ));
    }
    
    // Sort by ROI
    scenarios.sort((a, b) => b.roi.compareTo(a.roi));
    return scenarios;
  }
  
  static List<InvestmentRecommendation> _generateInvestmentRecommendations(
    double currentValue,
    List<RepairScenario> scenarios,
    MarketAnalysis marketAnalysis
  ) {
    final recommendations = <InvestmentRecommendation>[];
    
    final bestScenario = scenarios.isNotEmpty ? scenarios.first : null;
    
    if (bestScenario != null && bestScenario.roi > 50) {
      recommendations.add(InvestmentRecommendation(
        title: 'High ROI Repair Opportunity',
        description: '${bestScenario.title} offers excellent return on investment',
        recommendation: 'REPAIR',
        confidence: 0.9,
        expectedROI: bestScenario.roi,
        timeframe: bestScenario.timeToSell,
      ));
    } else if (currentValue > 20000 && marketAnalysis.marketVelocity > 0.8) {
      recommendations.add(InvestmentRecommendation(
        title: 'Premium Market Position',
        description: 'High-value device with strong market demand',
        recommendation: 'SELL_PREMIUM',
        confidence: 0.85,
        expectedROI: 0,
        timeframe: '1-2 days',
      ));
    } else if (currentValue < 5000) {
      recommendations.add(InvestmentRecommendation(
        title: 'Educational Impact Opportunity',
        description: 'Consider donation for student device program',
        recommendation: 'DONATE',
        confidence: 0.95,
        expectedROI: 0, // Social ROI
        timeframe: 'Immediate',
      ));
    } else {
      recommendations.add(InvestmentRecommendation(
        title: 'Local Market Sale',
        description: 'Standard sale in local market',
        recommendation: 'SELL_LOCAL',
        confidence: 0.75,
        expectedROI: 0,
        timeframe: '3-5 days',
      ));
    }
    
    return recommendations;
  }
  
  static double _calculateAnalysisConfidence(
    Map<String, dynamic>? deviceData, 
    DeviceHealth deviceHealth
  ) {
    double confidence = 0.6; // Base confidence
    
    if (deviceData != null) confidence += 0.2; // Device in database
    if (deviceHealth.identifiedIssues.isNotEmpty) confidence += 0.1; // More data points
    if (deviceHealth.batteryHealth > 0) confidence += 0.1; // Battery data available
    
    return confidence.clamp(0.5, 0.95);
  }
  
  static double _predictPriceStability(String deviceModel, Map<String, dynamic>? deviceData) {
    if (deviceData == null) return 0.7;
    
    final releaseYear = deviceData['releaseYear'] as int;
    final currentYear = DateTime.now().year;
    final ageYears = currentYear - releaseYear;
    
    // Newer devices have more volatile prices
    if (ageYears <= 1) return 0.6; // New devices depreciate quickly
    if (ageYears <= 3) return 0.8; // Stable mid-life
    return 0.9; // Older devices have stable, low prices
  }
  
  static String _calculateOptimalSellTime(String demandLevel, double priceStability) {
    if (demandLevel == 'high' && priceStability > 0.8) return 'Now - Peak demand';
    if (demandLevel == 'low') return 'Wait 1-2 months for seasonal demand';
    return 'Within 2 weeks - Good market conditions';
  }
  
  static List<String> _getCompetitiveDevices(String deviceModel) {
    final model = deviceModel.toLowerCase();
    
    if (model.contains('iphone')) {
      return ['Samsung Galaxy S series', 'Google Pixel', 'OnePlus flagships'];
    } else if (model.contains('samsung')) {
      return ['iPhone models', 'Xiaomi flagships', 'OnePlus devices'];
    } else if (model.contains('xiaomi')) {
      return ['Samsung A series', 'Oppo Reno', 'Vivo V series'];
    }
    
    return ['Similar price range devices'];
  }
}

// Enhanced data models for AI Value Engine
class ValueAnalysis {
  final double currentMarketValue;
  final List<RepairScenario> repairScenarios;
  final MarketAnalysis marketAnalysis;
  final List<InvestmentRecommendation> investmentRecommendations;
  final double confidenceScore;
  final DateTime analysisTimestamp;

  ValueAnalysis({
    required this.currentMarketValue,
    required this.repairScenarios,
    required this.marketAnalysis,
    required this.investmentRecommendations,
    required this.confidenceScore,
    required this.analysisTimestamp,
  });
}

class MarketAnalysis {
  final String currentDemand;
  final double marketVelocity;
  final double priceStability;
  final String optimalSellTime;
  final List<String> competitiveDevices;

  MarketAnalysis({
    required this.currentDemand,
    required this.marketVelocity,
    required this.priceStability,
    required this.optimalSellTime,
    required this.competitiveDevices,
  });
}

class RepairScenario {
  final String title;
  final String description;
  final double repairCost;
  final double postRepairValue;
  final double roi;
  final String timeToSell;
  final String riskLevel;

  RepairScenario({
    required this.title,
    required this.description,
    required this.repairCost,
    required this.postRepairValue,
    required this.roi,
    required this.timeToSell,
    required this.riskLevel,
  });
}

class InvestmentRecommendation {
  final String title;
  final String description;
  final String recommendation;
  final double confidence;
  final double expectedROI;
  final String timeframe;

  InvestmentRecommendation({
    required this.title,
    required this.description,
    required this.recommendation,
    required this.confidence,
    required this.expectedROI,
    required this.timeframe,
  });
}
