import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/models/resell_listing.dart';
import 'package:ayoayo/providers/resell_provider.dart';
import 'package:ayoayo/services/ai_resell_service.dart';

class ResellDetail extends StatelessWidget {
  final DiagnosisResult? diagnosisResult; // AI diagnostics result

  const ResellDetail({super.key, this.diagnosisResult});

  @override
  Widget build(BuildContext context) {
    return Consumer<ResellProvider>(
      builder: (context, resellProvider, child) {
        return Card(
          color: Colors.green[50],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "Resell Your Device",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildDeviceSummary(),
                const SizedBox(height: 16),
                _buildAIInsights(context),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(LucideIcons.shoppingBag),
                        label: const Text('Browse Marketplace'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/resell');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(LucideIcons.plus),
                        label: const Text('Create Listing'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green[700],
                          side: BorderSide(color: Colors.green[700]!),
                        ),
                        onPressed: () => _showCreateListingDialog(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildQuickStats(resellProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeviceSummary() {
    if (diagnosisResult == null) {
      return const Text(
        "Get an AI-powered valuation for your device and access our marketplace to find the best buyers.",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.smartphone, color: Colors.green[700]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Device Assessment",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildConditionRow(
            "Screen Condition",
            diagnosisResult!.deviceHealth.screenCondition.name,
            _getConditionColor(diagnosisResult!.deviceHealth.screenCondition),
          ),
          _buildConditionRow(
            "Overall Health",
            "${diagnosisResult!.deviceHealth.screenCondition.name} • ${diagnosisResult!.deviceHealth.hardwareCondition.name}",
            _getOverallHealthColor(diagnosisResult!.deviceHealth),
          ),
          _buildConditionRow(
            "Hardware Condition",
            diagnosisResult!.deviceHealth.hardwareCondition.name,
            _getHardwareColor(diagnosisResult!.deviceHealth.hardwareCondition),
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Estimated Value:"),
              Text(
                "₱${diagnosisResult!.valueEstimation.currentValue.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights(BuildContext context) {
    if (diagnosisResult == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.brain, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                "AI Market Insights",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<PricingStrategy>(
            future: _generatePricingStrategy(context, diagnosisResult!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                final strategy = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Optimal Price: ₱${strategy.optimalPrice.toStringAsFixed(0)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Expected Sale Time: ${strategy.expectedTimeframe}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                );
              }

              return const Text("AI insights loading...");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ResellProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          "Active Listings",
          "${provider.activeListings.length}",
          Colors.blue,
        ),
        _buildStatItem("Avg. Sale Time", "3-5 days", Colors.green),
        _buildStatItem("Success Rate", "85%", Colors.purple),
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
              color: color.withValues(alpha: 0.1),
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

  Future<PricingStrategy> _generatePricingStrategy(
    BuildContext context,
    DiagnosisResult diagnosisResult,
  ) async {
    try {
      final aiService = AIResellService(
        'AIzaSyCk6Ybk9etcuUz7n9VFWPrfPuZ4zNil9kQ',
      ); // Using the same API key
      return await aiService.generatePricingStrategy(
        _createDevicePassport(diagnosisResult),
        _getConditionGrade(diagnosisResult),
        diagnosisResult.valueEstimation.currentValue,
      );
    } catch (e) {
      // Return a default pricing strategy if AI fails
      return PricingStrategy(
        optimalPrice: diagnosisResult.valueEstimation.currentValue * 0.9,
        minimumPrice: diagnosisResult.valueEstimation.currentValue * 0.7,
        recommendedPrice: diagnosisResult.valueEstimation.currentValue * 0.85,
        justification: 'Fallback pricing based on device value',
        expectedTimeframe: '2-4 weeks',
        negotiationStrategy: 'Standard negotiation tactics',
      );
    }
  }

  DevicePassport _createDevicePassport(DiagnosisResult result) {
    // Extract manufacturer and other details from device model
    String manufacturer = 'Unknown';
    String deviceName = result.deviceModel;
    int yearOfRelease = 2020;

    if (result.deviceModel.toLowerCase().contains('iphone')) {
      manufacturer = 'Apple';
      yearOfRelease = 2022; // Default for newer iPhones
    } else if (result.deviceModel.toLowerCase().contains('samsung')) {
      manufacturer = 'Samsung';
      yearOfRelease = 2022;
    } else if (result.deviceModel.toLowerCase().contains('pixel')) {
      manufacturer = 'Google';
      yearOfRelease = 2022;
    }

    // Create a basic device passport from diagnosis result
    return DevicePassport(
      id: 'device_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_1', // In real app, get from auth
      deviceModel: deviceName,
      manufacturer: manufacturer,
      yearOfRelease: yearOfRelease,
      operatingSystem: manufacturer == 'Apple' ? 'iOS' : 'Android',
      imageUrls: result.imageUrls,
      lastDiagnosis: result,
    );
  }

  void _showCreateListingDialog(BuildContext context) async {
    if (diagnosisResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete device diagnosis first')),
      );
      return;
    }

    // Get condition grade for the listing
    final condition = _getConditionGrade(diagnosisResult!);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Listing'),
        content: const Text(
          'This will create an AI-optimized listing for your device on our marketplace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Navigate to resell screen to complete listing
              Navigator.pushNamed(context, '/resell');
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  ConditionGrade _getConditionGrade(DiagnosisResult result) {
    final screenGood =
        result.deviceHealth.screenCondition == ScreenCondition.excellent ||
        result.deviceHealth.screenCondition == ScreenCondition.good;
    final hardwareGood =
        result.deviceHealth.hardwareCondition == HardwareCondition.excellent ||
        result.deviceHealth.hardwareCondition == HardwareCondition.good;

    if (screenGood && hardwareGood) {
      return ConditionGrade.excellent;
    }
    if (screenGood || hardwareGood) return ConditionGrade.good;
    if (result.deviceHealth.screenCondition == ScreenCondition.cracked) {
      return ConditionGrade.damaged;
    }

    return ConditionGrade.fair;
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

  Color _getOverallHealthColor(DeviceHealth deviceHealth) {
    final screenGood = deviceHealth.screenCondition == ScreenCondition.excellent ||
                      deviceHealth.screenCondition == ScreenCondition.good;
    final hardwareGood = deviceHealth.hardwareCondition == HardwareCondition.excellent ||
                        deviceHealth.hardwareCondition == HardwareCondition.good;

    if (screenGood && hardwareGood) {
      return Colors.green;
    } else if (screenGood || hardwareGood) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
