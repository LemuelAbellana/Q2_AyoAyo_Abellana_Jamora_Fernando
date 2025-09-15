import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:ayoayo/models/technician.dart';
import 'package:ayoayo/services/technician_service.dart';
import 'package:ayoayo/utils/app_theme.dart';

class TechnicianFinderScreen extends StatefulWidget {
  const TechnicianFinderScreen({super.key});

  @override
  State<TechnicianFinderScreen> createState() => _TechnicianFinderScreenState();
}

class _TechnicianFinderScreenState extends State<TechnicianFinderScreen> {
  final TechnicianService _technicianService = TechnicianService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  List<Technician> _technicians = [];
  List<Technician> _filteredTechnicians = [];
  bool _isLoading = true;
  bool _showFilters = false;

  // Filter options
  String? _selectedSpecialization;
  double _minRating = 0.0;
  int _minExperience = 0;
  bool _onlyVetted = true;
  bool _onlyAvailable = true;

  final List<String> _specializations = [
    'Smartphones',
    'Laptops',
    'Tablets & Wearables',
    'Gaming Consoles',
    'Desktop Computers',
    'All Specializations'
  ];

  @override
  void initState() {
    super.initState();
    _initializeTechnicians();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _initializeTechnicians() async {
    setState(() => _isLoading = true);

    try {
      // Seed data first if needed
      await _technicianService.seedTechnicianData();

      // Load all vetted technicians
      final technicians = await _technicianService.getVettedTechnicians();
      print('🔧 Loaded ${technicians.length} technicians');

      setState(() {
        _technicians = technicians;
        _filteredTechnicians = technicians;
        _isLoading = false;
      });

      print('✅ Technician finder initialized successfully');
    } catch (e) {
      print('❌ Error loading technicians: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _applyFilters() async {
    setState(() => _isLoading = true);

    try {
      String? specialization = _selectedSpecialization == 'All Specializations'
          ? null
          : _selectedSpecialization;
      String? location = _locationController.text.isEmpty
          ? null
          : _locationController.text;

      final filteredTechnicians = await _technicianService.getTechniciansWithFilter(
        specialization: specialization,
        location: location,
        minRating: _minRating > 0 ? _minRating : null,
        minExperience: _minExperience > 0 ? _minExperience : null,
        onlyVetted: _onlyVetted,
        onlyAvailable: _onlyAvailable,
      );

      setState(() {
        _filteredTechnicians = filteredTechnicians;
        _isLoading = false;
      });
    } catch (e) {
      print('Error applying filters: $e');
      setState(() => _isLoading = false);
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedSpecialization = null;
      _locationController.clear();
      _minRating = 0.0;
      _minExperience = 0;
      _onlyVetted = true;
      _onlyAvailable = true;
      _filteredTechnicians = _technicians;
    });
  }

  void _searchTechnicians(String query) {
    if (query.isEmpty) {
      setState(() => _filteredTechnicians = _technicians);
      return;
    }

    final filtered = _technicians.where((technician) {
      return technician.name.toLowerCase().contains(query.toLowerCase()) ||
             technician.specialization.toLowerCase().contains(query.toLowerCase()) ||
             technician.city.toLowerCase().contains(query.toLowerCase()) ||
             technician.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() => _filteredTechnicians = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Technicians'),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? LucideIcons.x : LucideIcons.settings),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search technicians by name, specialization...',
                prefixIcon: Icon(LucideIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onChanged: _searchTechnicians,
            ),
          ),

          // Filters section
          if (_showFilters) _buildFilters(),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTechnicians.isEmpty
                    ? _buildEmptyState()
                    : _buildTechniciansList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Specialization dropdown
          DropdownButtonFormField<String>(
            value: _selectedSpecialization,
            decoration: const InputDecoration(
              labelText: 'Specialization',
              border: OutlineInputBorder(),
            ),
            items: _specializations.map((spec) {
              return DropdownMenuItem(value: spec, child: Text(spec));
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedSpecialization = value);
            },
          ),

          const SizedBox(height: 12),

          // Location input
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location (City/Province)',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          // Rating slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Minimum Rating: ${_minRating.toStringAsFixed(1)} ⭐'),
              Slider(
                value: _minRating,
                min: 0.0,
                max: 5.0,
                divisions: 10,
                onChanged: (value) {
                  setState(() => _minRating = value);
                },
              ),
            ],
          ),

          // Experience input
          TextField(
            decoration: const InputDecoration(
              labelText: 'Minimum Experience (years)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() => _minExperience = int.tryParse(value) ?? 0);
            },
          ),

          const SizedBox(height: 12),

          // Checkboxes
          Row(
            children: [
              Checkbox(
                value: _onlyVetted,
                onChanged: (value) {
                  setState(() => _onlyVetted = value ?? true);
                },
              ),
              const Text('Only Vetted Technicians'),
            ],
          ),

          Row(
            children: [
              Checkbox(
                value: _onlyAvailable,
                onChanged: (value) {
                  setState(() => _onlyAvailable = value ?? true);
                },
              ),
              const Text('Only Available Technicians'),
            ],
          ),

          const SizedBox(height: 12),

          // Apply filters button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.users,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No technicians found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _resetFilters,
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Widget _buildTechniciansList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _filteredTechnicians.length,
      itemBuilder: (context, index) {
        final technician = _filteredTechnicians[index];
        return _buildTechnicianCard(technician);
      },
    );
  }

  Widget _buildTechnicianCard(Technician technician) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and rating
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        technician.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        technician.specialization,
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(LucideIcons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      technician.ratingDisplay,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (technician.isVetted)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'VETTED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Location and experience
            Row(
              children: [
                Icon(LucideIcons.mapPin, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  technician.fullLocation,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Icon(LucideIcons.clock, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${technician.experienceYears} years exp',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              technician.description,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 8),

            // Skills
            if (technician.skills.isNotEmpty)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: technician.skills.take(3).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),

            // Contact button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showTechnicianDetails(technician),
                icon: const Icon(LucideIcons.messageCircle),
                label: const Text('Contact Technician'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTechnicianDetails(Technician technician) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryBlue,
                    child: Text(
                      technician.name.split(' ').map((e) => e[0]).join(''),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          technician.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          technician.specialization,
                          style: TextStyle(color: AppTheme.primaryBlue, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  if (technician.isVetted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '✓ Vetted',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Rating and stats
              Row(
                children: [
                  _buildStatItem(LucideIcons.star, technician.ratingDisplay, 'Rating'),
                  _buildStatItem(LucideIcons.clock, '${technician.experienceYears}y', 'Experience'),
                  _buildStatItem(LucideIcons.check, '${technician.completedRepairs}', 'Repairs'),
                ],
              ),

              const SizedBox(height: 20),

              // Description
              const Text(
                'About',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(technician.description),

              const SizedBox(height: 20),

              // Skills
              if (technician.skills.isNotEmpty) ...[
                const Text(
                  'Skills',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: technician.skills.map((skill) {
                    return Chip(
                      label: Text(skill),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // Certifications
              if (technician.certifications.isNotEmpty) ...[
                const Text(
                  'Certifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...technician.certifications.map((cert) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.award, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(cert),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
              ],

              // Location
              const Text(
                'Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(LucideIcons.mapPin, size: 16),
                  const SizedBox(width: 8),
                  Text(technician.fullLocation),
                ],
              ),

              const SizedBox(height: 20),

              // Contact buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement phone call functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${technician.contactPhone}')),
                        );
                      },
                      icon: const Icon(LucideIcons.phone),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement messaging functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Messaging ${technician.contactEmail}')),
                        );
                      },
                      icon: const Icon(LucideIcons.mail),
                      label: const Text('Message'),
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

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
