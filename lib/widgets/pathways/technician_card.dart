import 'package:flutter/material.dart';

class TechnicianCard extends StatelessWidget {
  final String name, location, quote;
  final double rating;
  const TechnicianCard({
    super.key,
    required this.name,
    required this.location,
    required this.rating,
    required this.quote,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(name),
        subtitle: Text(location),
        leading: CircleAvatar(child: Text(rating.toString())),
        trailing: Text(
          quote,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
