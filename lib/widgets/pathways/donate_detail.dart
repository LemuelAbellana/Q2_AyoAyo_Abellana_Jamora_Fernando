import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../screens/donation_screen.dart';

class DonateDetail extends StatelessWidget {
  const DonateDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.pink[50]!, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.pink[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      LucideIcons.heart,
                      color: Colors.pink[700],
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tech-Pahiram Program",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[800],
                          ),
                        ),
                        Text(
                          "Give your device a second life",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description
              Text(
                "Your old device can be a new beginning for a student in Davao. We partner with local schools to give your device a second life where it's needed most.",
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.left,
              ),

              const SizedBox(height: 24),

              // Impact Statistics
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.pink[100]?.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pink[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.trendingUp,
                          color: Colors.pink[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Impact So Far",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.pink[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem("348", "Devices Donated", LucideIcons.smartphone),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.pink[200],
                        ),
                        Expanded(
                          child: _buildStatItem("127", "Students Helped", LucideIcons.graduationCap),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Benefits Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          LucideIcons.leaf,
                          color: Colors.green[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Why Donate?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBenefitItem("Help students access technology for education"),
                    _buildBenefitItem("Reduce electronic waste in landfills"),
                    _buildBenefitItem("Support local community development"),
                    _buildBenefitItem("Get tax deduction receipts"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Call to Action Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(LucideIcons.heart, size: 20),
                      label: const Text(
                        'Start Donation Process',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[600],
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DonationScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      icon: Icon(LucideIcons.info, size: 18, color: Colors.pink[600]),
                      label: Text(
                        'Learn More About Tech-Pahiram',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.pink[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.pink[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Show info dialog
                        _showProgramInfo(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String number, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.pink[600], size: 24),
        const SizedBox(height: 4),
        Text(
          number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.pink[700],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            LucideIcons.check,
            color: Colors.green[600],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgramInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(LucideIcons.info, color: Colors.pink[600]),
            const SizedBox(width: 8),
            const Text("About Tech-Pahiram"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tech-Pahiram is our flagship donation program that bridges the digital divide in Davao City and surrounding areas.",
              style: TextStyle(height: 1.4, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Text(
              "How it works:",
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            _buildInfoStep("1. Diagnose your device using our AI tool"),
            _buildInfoStep("2. Choose donation pathway if device is suitable"),
            _buildInfoStep("3. Connect with verified students in need"),
            _buildInfoStep("4. Arrange secure device transfer"),
            _buildInfoStep("5. Receive impact report and tax receipt"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: TextStyle(color: Colors.pink[600])),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(LucideIcons.arrowRight, size: 14, color: Colors.pink[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

