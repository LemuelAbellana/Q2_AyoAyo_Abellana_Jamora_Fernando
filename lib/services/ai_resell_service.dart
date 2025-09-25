import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ayoayo/models/resell_listing.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/services/ai_value_engine.dart';

class AIResellService {
  final GenerativeModel _model;

  AIResellService(String apiKey)
    : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  /// Generate optimal listing title and description for a device
  Future<ListingContent> generateListingContent(
    DevicePassport devicePassport,
    ConditionGrade condition,
  ) async {
    final prompt =
        '''
You are an expert e-commerce listing writer for refurbished electronics. Create compelling, SEO-optimized content for a ${devicePassport.deviceModel} resale listing.

Device Details:
- Model: ${devicePassport.deviceModel}
- Manufacturer: ${devicePassport.manufacturer}
- Year: ${devicePassport.yearOfRelease}
- OS: ${devicePassport.operatingSystem}
- Condition: ${condition.toString().split('.').last}
- Screen Condition: ${devicePassport.lastDiagnosis.deviceHealth.screenCondition.toString().split('.').last}
- Hardware Condition: ${devicePassport.lastDiagnosis.deviceHealth.hardwareCondition.toString().split('.').last}
- Issues: ${devicePassport.lastDiagnosis.deviceHealth.identifiedIssues.join(', ')}

Create:
1. A catchy, SEO-friendly title (under 80 characters)
2. A detailed, persuasive description highlighting positives and being transparent about condition
3. Key selling points (bullet points)
4. SEO keywords for better discoverability

Focus on:
- Emphasizing device capabilities and remaining value
- Being transparent about condition and any repairs needed
- Highlighting the environmental benefit of buying refurbished
- Creating urgency and trust
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final content = response.text ?? '';

      // Parse the AI response to extract title and description
      return _parseListingContent(content, devicePassport);
    } catch (e) {
      // Fallback content generation
      return _generateFallbackContent(devicePassport, condition);
    }
  }

  /// Generate AI-powered pricing strategy
  Future<PricingStrategy> generatePricingStrategy(
    DevicePassport devicePassport,
    ConditionGrade condition,
    double baseValue,
  ) async {
    final marketAnalysis = AIValueEngine.analyzeDeviceValue(
      devicePassport.deviceModel,
      devicePassport.lastDiagnosis.deviceHealth,
    );

    final prompt =
        '''
Analyze this device's market position for optimal pricing strategy:

Device: ${devicePassport.deviceModel}
Base Value: ₱${baseValue.toStringAsFixed(2)}
Condition: ${condition.toString().split('.').last}
Market Demand: ${marketAnalysis.marketAnalysis.currentDemand}
Market Velocity: ${(marketAnalysis.marketAnalysis.marketVelocity * 100).toStringAsFixed(0)}%

Provide pricing recommendations including:
1. Optimal listing price
2. Minimum acceptable price
3. Price justification
4. Expected sale timeframe
5. Negotiation strategy
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parsePricingStrategy(response.text ?? '', baseValue);
    } catch (e) {
      return _generateFallbackPricing(baseValue, condition);
    }
  }

  /// Generate buyer matching recommendations
  Future<List<BuyerMatch>> findPotentialBuyers(ResellListing listing) async {
    final prompt =
        '''
Based on this device listing, identify potential buyer profiles and matching strategies:

Listing: ${listing.title}
Device: ${listing.devicePassport.deviceModel}
Price: ₱${listing.askingPrice.toStringAsFixed(2)}
Condition: ${listing.condition.toString().split('.').last}

Suggest:
1. Target buyer demographics
2. Marketing channels
3. Competitive advantages
4. Pricing positioning
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseBuyerMatches(response.text ?? '');
    } catch (e) {
      return _generateFallbackBuyers(listing);
    }
  }

  /// Analyze market competition for a device
  Future<MarketCompetition> analyzeCompetition(
    String deviceModel,
    double askingPrice,
  ) async {
    final prompt =
        '''
Analyze the competitive landscape for selling a $deviceModel at ₱${askingPrice.toStringAsFixed(2)}:

Market Data:
- Average prices for similar devices
- Current demand trends
- Competing platforms
- Seasonal factors

Provide:
1. Competitive price analysis
2. Market positioning recommendations
3. Unique selling propositions
4. Timing recommendations
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseMarketCompetition(response.text ?? '');
    } catch (e) {
      return _generateFallbackCompetition();
    }
  }

  /// Generate sales optimization tips
  Future<List<String>> generateSalesTips(ResellListing listing) async {
    final prompt =
        '''
Generate actionable tips to improve sales for this listing:

Device: ${listing.devicePassport.deviceModel}
Current Price: ₱${listing.askingPrice.toStringAsFixed(2)}
Condition: ${listing.condition.toString().split('.').last}
Days Listed: ${listing.daysActive}

Provide 5-7 specific, actionable tips to increase sale probability.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return _parseSalesTips(response.text ?? '');
    } catch (e) {
      return [
        'Add more high-quality photos showing different angles',
        'Highlight the device\'s remaining features and capabilities',
        'Offer buyer protection or return policy',
        'Use urgent but honest language in description',
        'Consider price adjustment based on market feedback',
        'Promote on multiple platforms',
        'Respond quickly to buyer inquiries',
      ];
    }
  }

  // Helper methods for parsing AI responses
  ListingContent _parseListingContent(String content, DevicePassport device) {
    final lines = content.split('\n');
    String title = '';
    String description = '';
    List<String> keyPoints = [];

    // Extract title (usually first line or clearly marked)
    for (final line in lines) {
      if (line.toLowerCase().contains('title') || line.length < 80) {
        title = line.replaceAll('Title:', '').replaceAll('"', '').trim();
        break;
      }
    }

    // Extract description
    final descStart = content.indexOf('description');
    if (descStart != -1) {
      description = content.substring(descStart).split('\n\n')[0];
    }

    // Extract key points
    final bulletPoints = lines
        .where(
          (line) =>
              line.trim().startsWith('•') ||
              line.trim().startsWith('-') ||
              line.trim().startsWith('*'),
        )
        .toList();

    keyPoints = bulletPoints
        .map(
          (point) => point
              .replaceAll('•', '')
              .replaceAll('-', '')
              .replaceAll('*', '')
              .trim(),
        )
        .toList();

    return ListingContent(
      title: title.isNotEmpty
          ? title
          : '${device.deviceModel} - ${device.manufacturer}',
      description: description.isNotEmpty
          ? description
          : 'Quality refurbished ${device.deviceModel} in good condition.',
      keySellingPoints: keyPoints,
      seoKeywords: _generateSEOKeywords(device),
    );
  }

  PricingStrategy _parsePricingStrategy(String content, double baseValue) {
    // Simple parsing - in production, use more sophisticated parsing
    final optimalPrice = baseValue * 0.9; // Conservative estimate
    final minPrice = baseValue * 0.7;

    return PricingStrategy(
      optimalPrice: optimalPrice,
      minimumPrice: minPrice,
      recommendedPrice: optimalPrice,
      justification:
          'AI analysis based on market conditions and device condition',
      expectedTimeframe: '2-4 weeks',
      negotiationStrategy: 'Start firm, offer 5-10% discount for quick sale',
    );
  }

  List<BuyerMatch> _parseBuyerMatches(String content) {
    return [
      BuyerMatch(
        profile: 'Budget-conscious students',
        channels: ['Facebook Marketplace', 'School groups'],
        advantages: ['Price sensitivity', 'Brand loyalty'],
        conversionTips: [
          'Emphasize value for money',
          'Offer student discounts',
        ],
      ),
      BuyerMatch(
        profile: 'Tech enthusiasts',
        channels: ['Reddit r/gadgets', 'Tech forums'],
        advantages: ['Knowledgeable buyers', 'Willing to pay premium'],
        conversionTips: ['Highlight specifications', 'Provide detailed specs'],
      ),
    ];
  }

  MarketCompetition _parseMarketCompetition(String content) {
    return MarketCompetition(
      averagePrice: 0,
      pricePositioning: 'competitive',
      uniqueAdvantages: ['Certified condition', 'Environmental impact'],
      recommendedActions: [
        'Maintain current pricing',
        'Highlight unique features',
      ],
    );
  }

  List<String> _parseSalesTips(String content) {
    final lines = content.split('\n');
    return lines
        .where(
          (line) =>
              line.trim().isNotEmpty &&
              !line.toLowerCase().contains('tips') &&
              !line.toLowerCase().contains('generate'),
        )
        .take(7)
        .toList();
  }

  // Fallback methods
  ListingContent _generateFallbackContent(
    DevicePassport device,
    ConditionGrade condition,
  ) {
    return ListingContent(
      title:
          'Refurbished ${device.deviceModel} - ${condition.toString().split('.').last} Condition',
      description:
          'Quality refurbished ${device.deviceModel} from ${device.manufacturer}. '
          'This device is in ${condition.toString().split('.').last} condition and offers great value. '
          'Help reduce e-waste by giving this device a second life!',
      keySellingPoints: [
        'Fully functional with ${device.operatingSystem}',
        'Transparent condition reporting',
        'Environmentally friendly purchase',
        'Competitive pricing',
        '${device.lastDiagnosis.deviceHealth.screenCondition.name} screen condition',
        '${device.lastDiagnosis.deviceHealth.hardwareCondition.name} hardware',
      ],
      seoKeywords: _generateSEOKeywords(device),
    );
  }

  PricingStrategy _generateFallbackPricing(
    double baseValue,
    ConditionGrade condition,
  ) {
    double multiplier;
    switch (condition) {
      case ConditionGrade.excellent:
        multiplier = 0.95;
        break;
      case ConditionGrade.good:
        multiplier = 0.85;
        break;
      case ConditionGrade.fair:
        multiplier = 0.75;
        break;
      case ConditionGrade.poor:
        multiplier = 0.6;
        break;
      case ConditionGrade.damaged:
        multiplier = 0.4;
        break;
    }

    final optimalPrice = baseValue * multiplier;

    return PricingStrategy(
      optimalPrice: optimalPrice,
      minimumPrice: optimalPrice * 0.8,
      recommendedPrice: optimalPrice,
      justification: 'Based on device condition and market analysis',
      expectedTimeframe: '1-3 weeks',
      negotiationStrategy: 'Offer 5-15% discount for serious buyers',
    );
  }

  List<BuyerMatch> _generateFallbackBuyers(ResellListing listing) {
    return [
      BuyerMatch(
        profile: 'General consumers',
        channels: ['Facebook Marketplace', 'Local classifieds'],
        advantages: ['Large audience', 'Local pickup preference'],
        conversionTips: [
          'Clear photos',
          'Detailed description',
          'Competitive pricing',
        ],
      ),
    ];
  }

  MarketCompetition _generateFallbackCompetition() {
    return MarketCompetition(
      averagePrice: 0,
      pricePositioning: 'market_average',
      uniqueAdvantages: ['Detailed device history', 'AI-powered valuation'],
      recommendedActions: [
        'Monitor competitor prices',
        'Highlight unique features',
      ],
    );
  }

  List<String> _generateSEOKeywords(DevicePassport device) {
    return [
      device.deviceModel,
      device.manufacturer,
      'refurbished',
      'second hand',
      device.operatingSystem,
      'smartphone',
      'mobile phone',
      'used electronics',
      'sustainable',
      'eco-friendly',
    ];
  }
}

// Data classes for AI responses
class ListingContent {
  final String title;
  final String description;
  final List<String> keySellingPoints;
  final List<String> seoKeywords;

  ListingContent({
    required this.title,
    required this.description,
    required this.keySellingPoints,
    required this.seoKeywords,
  });
}

class PricingStrategy {
  final double optimalPrice;
  final double minimumPrice;
  final double recommendedPrice;
  final String justification;
  final String expectedTimeframe;
  final String negotiationStrategy;

  PricingStrategy({
    required this.optimalPrice,
    required this.minimumPrice,
    required this.recommendedPrice,
    required this.justification,
    required this.expectedTimeframe,
    required this.negotiationStrategy,
  });
}

class BuyerMatch {
  final String profile;
  final List<String> channels;
  final List<String> advantages;
  final List<String> conversionTips;

  BuyerMatch({
    required this.profile,
    required this.channels,
    required this.advantages,
    required this.conversionTips,
  });
}

class MarketCompetition {
  final double averagePrice;
  final String pricePositioning;
  final List<String> uniqueAdvantages;
  final List<String> recommendedActions;

  MarketCompetition({
    required this.averagePrice,
    required this.pricePositioning,
    required this.uniqueAdvantages,
    required this.recommendedActions,
  });
}
