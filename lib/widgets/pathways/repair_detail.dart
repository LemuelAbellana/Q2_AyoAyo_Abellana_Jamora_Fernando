import 'package:flutter/material.dart';
import '/widgets/pathways/technician_card.dart';

class RepairDetail extends StatelessWidget {
  const RepairDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Find a Vetted Technician",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            'https://placehold.co/600x300/e2e8f0/64748b?text=Map+of+Davao+Shops',
          ),
        ),
        const SizedBox(height: 16),
        const TechnicianCard(
          name: "Juan's Gadget Repair",
          location: "Uyanguren",
          rating: 4.8,
          quote: "₱1,500",
        ),
        const TechnicianCard(
          name: "TechFix Bankerohan",
          location: "Bankerohan",
          rating: 4.7,
          quote: "₱1,650",
        ),
      ],
    );
  }
}
