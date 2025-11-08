import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../models/resell_listing.dart';
import '../../models/device_diagnosis.dart';
import '../../utils/app_theme.dart';
import '../../utils/enum_helpers.dart';

class GlassmorphicListingCard extends StatelessWidget {
  final ResellListing listing;
  final VoidCallback onTap;

  const GlassmorphicListingCard({
    super.key,
    required this.listing,
    required this.onTap,
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
            blurRadius: 20,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with title and condition badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              listing.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _buildConditionBadge(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Device info card
                      _buildDeviceInfoCard(),

                      const SizedBox(height: 16),

                      // Location and time
                      Row(
                        children: [
                          if (listing.location != null &&
                              listing.location!.isNotEmpty) ...[
                            Icon(
                              LucideIcons.mapPin,
                              size: 16,
                              color: AppTheme.primaryGreen,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                listing.location!,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Icon(
                            LucideIcons.clock,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${listing.daysActive} ${listing.daysActive == 1 ? 'day' : 'days'} ago',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Price section with glassmorphic effect
                      _buildPriceSection(),

                      const SizedBox(height: 16),

                      // Hardware health and views
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getHardwareColor(
                                    listing
                                        .devicePassport
                                        .lastDiagnosis
                                        .deviceHealth
                                        .hardwareCondition,
                                  ).withValues(alpha: 0.2),
                                  _getHardwareColor(
                                    listing
                                        .devicePassport
                                        .lastDiagnosis
                                        .deviceHealth
                                        .hardwareCondition,
                                  ).withValues(alpha: 0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getHardwareColor(
                                  listing
                                      .devicePassport
                                      .lastDiagnosis
                                      .deviceHealth
                                      .hardwareCondition,
                                ).withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.cpu,
                                  size: 16,
                                  color: _getHardwareColor(
                                    listing
                                        .devicePassport
                                        .lastDiagnosis
                                        .deviceHealth
                                        .hardwareCondition,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${getEnumName(listing.devicePassport.lastDiagnosis.deviceHealth.hardwareCondition)} Hardware',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getHardwareColor(
                                      listing
                                          .devicePassport
                                          .lastDiagnosis
                                          .deviceHealth
                                          .hardwareCondition,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            LucideIcons.eye,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${(listing.daysActive * 8 + 15).toStringAsFixed(0)} views',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Widget _buildConditionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getConditionColor(listing.condition).withValues(alpha: 0.2),
            _getConditionColor(listing.condition).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _getConditionColor(listing.condition).withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Text(
        _getConditionDisplayName(listing.condition),
        style: TextStyle(
          color: _getConditionColor(listing.condition),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.smartphone,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${listing.devicePassport.deviceModel} • ${listing.devicePassport.manufacturer}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryGreen.withValues(alpha: 0.12),
                AppTheme.primaryBlue.withValues(alpha: 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryGreen.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.primaryGradient.createShader(bounds),
                    child: Text(
                      '₱${listing.askingPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (listing.aiSuggestedPrice != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'AI suggests: ₱${listing.aiSuggestedPrice!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              if (listing.aiSuggestedPrice != null &&
                  listing.priceDifference.abs() > 1000) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: listing.isPriceOptimal
                          ? [
                              Colors.green.withValues(alpha: 0.2),
                              Colors.green.withValues(alpha: 0.1),
                            ]
                          : [
                              Colors.orange.withValues(alpha: 0.2),
                              Colors.orange.withValues(alpha: 0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: listing.isPriceOptimal
                          ? Colors.green.withValues(alpha: 0.4)
                          : Colors.orange.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        listing.isPriceOptimal
                            ? LucideIcons.trendingUp
                            : LucideIcons.triangleAlert,
                        size: 16,
                        color: listing.isPriceOptimal
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        listing.isPriceOptimal ? 'Optimal' : 'Adjust',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: listing.isPriceOptimal
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getConditionColor(ConditionGrade condition) {
    switch (condition) {
      case ConditionGrade.excellent:
        return Colors.green;
      case ConditionGrade.good:
        return Colors.blue;
      case ConditionGrade.fair:
        return Colors.orange;
      case ConditionGrade.poor:
        return Colors.red;
      case ConditionGrade.damaged:
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

  String _getConditionDisplayName(ConditionGrade condition) {
    switch (condition) {
      case ConditionGrade.excellent:
        return 'Excellent';
      case ConditionGrade.good:
        return 'Good';
      case ConditionGrade.fair:
        return 'Fair';
      case ConditionGrade.poor:
        return 'Poor';
      case ConditionGrade.damaged:
        return 'Damaged';
    }
  }
}




