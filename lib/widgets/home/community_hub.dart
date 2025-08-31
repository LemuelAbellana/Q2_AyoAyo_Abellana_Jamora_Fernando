import 'package:ayoayo/screens/technician_chatbot_screen.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class CommunityHub extends StatelessWidget {
  const CommunityHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "AyoAyo Community Hub",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(LucideIcons.graduationCap, size: 40, color: Colors.blue),
                  const SizedBox(height: 8),
                  const Text(
                    "AyoAyo University",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.bot, color: Colors.blue),
                    title: const Text("Technician Chatbot"),
                    subtitle: const Text("Get instant help from our AI assistant"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TechnicianChatbotScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.green[600],
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(LucideIcons.shieldCheck, size: 40, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    "Davao E-Waste Tracker",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            "1,523",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Devices Saved",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            "850kg",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "E-Waste Diverted",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
