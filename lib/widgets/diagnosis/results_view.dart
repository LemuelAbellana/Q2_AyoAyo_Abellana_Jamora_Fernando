import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '/models/pathway.dart';
import '/widgets/pathways/donate_detail.dart';
import '/widgets/pathways/pathway_card.dart';
import '/widgets/pathways/repair_detail.dart';

class ResultsView extends StatelessWidget {
  final Pathway selectedPathway;
  final Function(Pathway) onPathwaySelected;

  const ResultsView({
    super.key,
    required this.selectedPathway,
    required this.onPathwaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _DevicePassportCard(),
        const SizedBox(height: 16),
        const _ValueEngineCard(),
        const SizedBox(height: 24),
        const Text(
          "2. Choose Your Pathway",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            PathwayCard(
              label: 'Repair It',
              icon: LucideIcons.wrench,
              color: Colors.green,
              isSelected: selectedPathway == Pathway.repair,
              onTap: () => onPathwaySelected(Pathway.repair),
            ),
            PathwayCard(
              label: 'Resell',
              icon: LucideIcons.handshake,
              color: Colors.blue,
              isSelected: selectedPathway == Pathway.resell,
              onTap: () => onPathwaySelected(Pathway.resell),
            ),
            PathwayCard(
              label: 'Upcycle',
              icon: LucideIcons.recycle,
              color: Colors.grey,
              isSelected: selectedPathway == Pathway.upcycle,
              onTap: () => onPathwaySelected(Pathway.upcycle),
            ),
            PathwayCard(
              label: 'Donate It',
              icon: LucideIcons.heart,
              color: Colors.pink,
              isSelected: selectedPathway == Pathway.donate,
              onTap: () => onPathwaySelected(Pathway.donate),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Display details based on selected pathway
        if (selectedPathway == Pathway.repair) const RepairDetail(),
        if (selectedPathway == Pathway.donate) const DonateDetail(),
      ],
    );
  }
}

class _DevicePassportCard extends StatelessWidget {
  const _DevicePassportCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Device Passport",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: Icon(LucideIcons.batteryWarning, color: Colors.red),
              title: Text("Battery Health"),
              trailing: Text(
                "78%",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: Icon(LucideIcons.smartphone, color: Colors.green),
              title: Text("Screen"),
              trailing: Text(
                "Good",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueEngineCard extends StatelessWidget {
  const _ValueEngineCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dynamic Value Engine",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("As-Is Value:"),
                Text("₱25,000", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Post-Repair Value:"),
                Text(
                  "₱28,500",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Parts Value:"),
                Text("₱7,000", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
