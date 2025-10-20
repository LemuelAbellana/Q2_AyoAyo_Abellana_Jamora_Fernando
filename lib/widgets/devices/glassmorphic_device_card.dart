import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../models/device_passport.dart';
import '../../models/device_diagnosis.dart';
import '../../utils/app_theme.dart';

class GlassmorphicDeviceCard extends StatelessWidget {
  final DevicePassport device;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const GlassmorphicDeviceCard({
    super.key,
    required this.device,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Device icon with gradient
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          LucideIcons.smartphone,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Device info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.deviceModel,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.cpu,
                                  size: 14,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  device.manufacturer,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Condition badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getConditionColor(
                                      device
                                          .lastDiagnosis
                                          .deviceHealth
                                          .screenCondition,
                                    ).withValues(alpha: 0.2),
                                    _getConditionColor(
                                      device
                                          .lastDiagnosis
                                          .deviceHealth
                                          .screenCondition,
                                    ).withValues(alpha: 0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _getConditionColor(
                                    device
                                        .lastDiagnosis
                                        .deviceHealth
                                        .screenCondition,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.heart,
                                    size: 12,
                                    color: _getConditionColor(
                                      device
                                          .lastDiagnosis
                                          .deviceHealth
                                          .screenCondition,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getConditionText(
                                      device
                                          .lastDiagnosis
                                          .deviceHealth
                                          .screenCondition,
                                    ),
                                    style: TextStyle(
                                      color: _getConditionColor(
                                        device
                                            .lastDiagnosis
                                            .deviceHealth
                                            .screenCondition,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Value
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.dollarSign,
                                  size: 14,
                                  color: AppTheme.primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                ShaderMask(
                                  shaderCallback: (bounds) => AppTheme
                                      .primaryGradient
                                      .createShader(bounds),
                                  child: Text(
                                    '${device.lastDiagnosis.valueEstimation.currency}${device.estimatedValue.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Menu button
                      if (onDelete != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              LucideIcons.trash2,
                              size: 20,
                              color: Colors.red.shade700,
                            ),
                            onPressed: onDelete,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

  String _getConditionText(ScreenCondition condition) {
    switch (condition) {
      case ScreenCondition.excellent:
        return 'Excellent';
      case ScreenCondition.good:
        return 'Good';
      case ScreenCondition.fair:
        return 'Fair';
      case ScreenCondition.poor:
        return 'Poor';
      case ScreenCondition.cracked:
        return 'Cracked';
      case ScreenCondition.unknown:
        return 'Unknown';
    }
  }
}
