import 'package:flutter/material.dart';
import 'package:ayoayo/models/device_diagnosis.dart';

class RecommendationsView extends StatelessWidget {
  final List<RecommendedAction> recommendations;

  const RecommendationsView({Key? key, required this.recommendations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = recommendations[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: Icon(_getRecommendationIcon(recommendation.type)),
            title: Text(recommendation.title),
            subtitle: Text(recommendation.description),
          ),
        );
      },
    );
  }

  IconData _getRecommendationIcon(ActionType type) {
    switch (type) {
      case ActionType.repair:
        return Icons.build;
      case ActionType.replace:
        return Icons.autorenew;
      case ActionType.donate:
        return Icons.volunteer_activism;
      case ActionType.recycle:
        return Icons.recycling;
      case ActionType.sell:
        return Icons.sell;
      case ActionType.other:
        return Icons.help_outline;
    }
  }
}
