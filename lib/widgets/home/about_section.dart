import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.blue[50],
      child: const Column(
        children: [
          Text(
            "Our Mission in Davao",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            "We're building a circular economy for electronics, right here in Davao City. By empowering Davaoeños to make smarter choices, we can reduce e-waste, save money, and give our gadgets a second, third, or even fourth life. Maayo pa, Davaoeño!",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
