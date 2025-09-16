import 'package:ayoayo/screens/technician_chatbot_screen.dart';
import 'package:ayoayo/models/technician.dart';
import 'package:ayoayo/services/technician_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class RepairDetail extends StatefulWidget {
  const RepairDetail({super.key});

  @override
  State<RepairDetail> createState() => _RepairDetailState();
}

class _RepairDetailState extends State<RepairDetail> {
  final TechnicianService _technicianService = TechnicianService();
  List<Technician> _availableTechnicians = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    print('🚀 RepairDetail initialized - loading technicians...');
    _loadAvailableTechnicians();
  }

  Future<void> _loadAvailableTechnicians() async {
    try {
      print('🔧 Loading available technicians...');
      // Seed data first if needed
      await _technicianService.seedTechnicianData();

      // Load all available vetted technicians
      final technicians = await _technicianService.getVettedTechnicians();

      print('✅ Found ${technicians.length} technicians');
      setState(() {
        _availableTechnicians = technicians.take(5).toList(); // Show top 5 technicians
        _isLoading = false;
      });
      print('📱 UI Updated: ${_availableTechnicians.length} technicians displayed, loading: $_isLoading');
    } catch (e) {
      print('❌ Error loading Davao technicians: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blueAccent),
    );
  }

  Widget _buildCommunityHub() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Community & Learning Hub",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.forum),
              title: const Text("Technician Chatbot"),
              subtitle: const Text("Get instant help from our AI assistant"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TechnicianChatbotScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDavaoTechniciansSection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Technicians",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "Connect with certified technicians across the Philippines",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_availableTechnicians.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "No technicians available at the moment.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ..._availableTechnicians.map((technician) {
              print('👨‍🔧 Displaying technician: ${technician.name}');
              return _buildTechnicianCard(technician);
            }),

          // Quick action buttons
          if (_availableTechnicians.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Need urgent repair?",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Call our top-rated technician directly",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final topTech = _availableTechnicians.first;
                        _showSnackBar('📞 Calling ${topTech.name}...');
                      },
                      icon: const Icon(Icons.phone, color: Colors.white),
                      label: Text('Call ${(_availableTechnicians.first).name.split(' ').first}'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Additional technician info
          if (_availableTechnicians.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "All technicians are verified",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Showing ${_availableTechnicians.length} certified technicians ready to help",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTechnicianCard(Technician technician) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Technician Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                technician.name.split(' ').map((e) => e[0]).join(''),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Technician Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    technician.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    technician.specialization,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        technician.fullLocation,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Rating and Contact
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      technician.ratingDisplay,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (technician.isVetted)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'VETTED',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showSnackBar('Calling ${technician.contactPhone}...');
                      },
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    OutlinedButton(
                      onPressed: () {
                        _showSnackBar('Email sent to ${technician.contactEmail}');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Message'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationPathway() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.favorite, color: Colors.green, size: 32),
              const SizedBox(height: 8),
              const Text(
                "Device Still Usable?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Consider donating it to a local student.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    _showSnackBar("Starting the donation process..."),
                child: const Text("Donate to a Student"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshTechnicians() async {
    setState(() => _isLoading = true);
    await _loadAvailableTechnicians();
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 Building RepairDetail UI - loading: $_isLoading, technicians: ${_availableTechnicians.length}');
    print('📱 Current UI state: ${WidgetsBinding.instance.lifecycleState}');

    // Force rebuild to ensure latest state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 Post-frame callback - technicians loaded: ${_availableTechnicians.length}');
    });

    return RefreshIndicator(
      onRefresh: _refreshTechnicians,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade600, Colors.blue.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available Repair Technicians",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Connect directly with certified technicians for your device repairs",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildDavaoTechniciansSection(),
              const Divider(height: 48, thickness: 1),
              _buildCommunityHub(),
              const Divider(height: 48, thickness: 1),
              _buildDonationPathway(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}