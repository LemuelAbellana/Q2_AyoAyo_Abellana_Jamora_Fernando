import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class DonateDetail extends StatelessWidget {
  const DonateDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.pink[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Tech-Pahiram Program",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Your old device can be a new beginning for a student in Davao. We partner with local schools to give your device a second life where it's needed most.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.gift),
              label: const Text('Start Donation Process'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Placeholder for donation logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
