import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Data Models ---

class TechnicianReview {
  final String author;
  final String comment;
  final double rating;
  TechnicianReview(this.author, this.comment, this.rating);
}

class Technician {
  final String id;
  final String name;
  final String location; // For the summary card (e.g., "Uyanguren")
  final String address; // For the detailed dialog view
  final String specialty;
  final double rating;
  final String priceRange;
  final double distance;
  final String operatingHours;
  final List<TechnicianReview> reviews;
  final String shopImageUrl;

  const Technician({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.specialty,
    required this.rating,
    required this.priceRange,
    required this.distance,
    required this.operatingHours,
    required this.reviews,
    required this.shopImageUrl,
  });
}

enum FilterOption { rating, distance, price }

// --- Main Widget ---

class RepairDetail extends StatefulWidget {
  const RepairDetail({super.key});

  @override
  State<RepairDetail> createState() => _RepairDetailState();
}

class _RepairDetailState extends State<RepairDetail> {
  // --- State ---
  final List<Technician> _allTechnicians = [
    Technician(
        id: 'tech1',
        name: "Juan's Gadget Repair",
        location: "Uyanguren",
        address: "Rm 301, 123 San Pedro Street, Brgy. Poblacion, Davao City",
        specialty: "Expert in Screen & Battery",
        rating: 4.8,
        priceRange: "₱1200 - ₱1800",
        distance: 2.1,
        operatingHours: "Open: 9:00 AM • Closes: 6:00 PM",
        shopImageUrl: 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?q=80&w=870&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        reviews: [
          TechnicianReview("Maria S.", "Fast and reliable screen replacement!", 5.0),
          TechnicianReview("Pedro T.", "Very professional service.", 4.5),
        ]),
    Technician(
        id: 'tech2',
        name: "TechFix Bankerohan",
        location: "Bankerohan Public Market",
        address: "Stall 42, Bankerohan Public Market, Marfori St, Davao City",
        specialty: "Motherboard Specialist",
        rating: 4.7,
        priceRange: "₱1500 - ₱2500",
        distance: 1.5,
        operatingHours: "Open: 10:00 AM • Closes: 7:00 PM",
        shopImageUrl: 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        reviews: [
          TechnicianReview("Anna G.", "Fixed my water-damaged phone when others couldn't.", 5.0),
        ]),
    Technician(
        id: 'tech3',
        name: "Davao Cellphone Hub",
        location: "Gaisano Mall",
        address: "3rd Floor, Cyberzone, Gaisano Mall of Davao, J.P. Laurel Ave, Davao City",
        specialty: "All-Around Repairs",
        rating: 4.9,
        priceRange: "₱1000 - ₱3000",
        distance: 3.5,
        operatingHours: "Open: 10:00 AM • Closes: 9:00 PM",
        shopImageUrl: 'https://images.unsplash.com/photo-1567880905822-56f8e06fe630?q=80&w=735&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        reviews: [
          TechnicianReview("John D.", "Best prices in town.", 5.0),
          TechnicianReview("Lisa M.", "Quick and easy transaction.", 4.5),
        ]),
  ];

  late List<Technician> _filteredTechnicians;
  final Set<FilterOption> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _filteredTechnicians = List.from(_allTechnicians);
    _applyFilters();
  }

  // --- Helper Methods & Dialogs ---

  void _toggleFilter(FilterOption option) {
    setState(() {
      if (_activeFilters.contains(option)) {
        _activeFilters.remove(option);
      } else {
        _activeFilters.add(option);
      }
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredTechnicians = List.from(_allTechnicians);

    _filteredTechnicians.sort((a, b) {
      int comparison = 0;
      for (var filter in _activeFilters) {
        if (comparison == 0) {
          switch (filter) {
            case FilterOption.rating:
              comparison = b.rating.compareTo(a.rating);
              break;
            case FilterOption.distance:
              comparison = a.distance.compareTo(b.distance);
              break;
            case FilterOption.price:
              comparison = a.priceRange.compareTo(b.priceRange);
              break;
          }
        }
      }
      return comparison;
    });
  }

  void _showTechnicianProfile(BuildContext context, Technician technician) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Center(
          child: Text(
            technician.name,
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: Image.network(
                    technician.shopImageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        technician.specialty,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Text("📍 ${technician.address}"), // Uses detailed address
                      const SizedBox(height: 4),
                      Text("🕒 ${technician.operatingHours}"), // Uses specific hours
                      const Divider(height: 24),
                      const Text("Recent Reviews",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ...technician.reviews.map((review) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                '"${review.comment}" - ${review.author} (${review.rating} ★)'),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop())
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blueAccent),
    );
  }

  // --- UI Builder Methods for Readability ---

  Widget _buildCommunityHub() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Community & Learning Hub",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text("1,523",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor)),
                    const Text("Devices Saved")
                  ]),
                  Column(children: [
                    Text("850kg",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor)),
                    const Text("E-Waste Diverted")
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildHubCard(Icons.school, "Tech-Care Guides",
                      () => _showSnackBar("Opening learning resources..."))),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildHubCard(Icons.forum, "Ask a Technician",
                      () => _showSnackBar("Opening community forum..."))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHubCard(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center)
            ],
          ),
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
              const Text("Device Still Usable?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text(
                  "Consider donating it to a local student in Davao City.",
                  textAlign: TextAlign.center),
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

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("Find a Vetted Technician",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    'https://virtual-tour.davaocity.gov.ph/wp-content/uploads/2022/02/san-pedro-cathedral-min-1.jpg',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _showSnackBar("Searching for technicians near you..."),
                    icon: const Icon(Icons.location_searching),
                    label: const Text("Near Me"),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                spacing: 8.0,
                children: [
                  FilterChip(
                    label: const Text('Top Rated'),
                    selected: _activeFilters.contains(FilterOption.rating),
                    onSelected: (_) => _toggleFilter(FilterOption.rating),
                  ),
                  FilterChip(
                    label: const Text('Closest'),
                    selected: _activeFilters.contains(FilterOption.distance),
                    onSelected: (_) => _toggleFilter(FilterOption.distance),
                  ),
                  FilterChip(
                    label: const Text('By Price'),
                    selected: _activeFilters.contains(FilterOption.price),
                    onSelected: (_) => _toggleFilter(FilterOption.price),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              itemCount: _filteredTechnicians.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final tech = _filteredTechnicians[index];
                return _TechnicianCard(
                  technician: tech,
                  onTap: () => _showTechnicianProfile(context, tech),
                  onBook: () => _showSnackBar("Booking with ${tech.name}..."),
                  onChat: () => _showSnackBar("Opening chat with ${tech.name}..."),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
            const Divider(height: 48, thickness: 1),
            _buildCommunityHub(),
            const Divider(height: 48, thickness: 1),
            _buildDonationPathway(),
          ],
        ),
      ),
    );
  }
}

// --- Improved TechnicianCard Widget ---
class _TechnicianCard extends StatelessWidget {
  final Technician technician;
  final VoidCallback onTap;
  final VoidCallback onBook;
  final VoidCallback onChat;

  const _TechnicianCard(
      {required this.technician,
      required this.onTap,
      required this.onBook,
      required this.onChat});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      technician.shopImageUrl,
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(technician.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            "${technician.location} • ${technician.distance}km away", // Uses summary location
                            style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(technician.rating.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    technician.priceRange,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                "Specialty: ${technician.specialty}",
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text("Chat"),
                      onPressed: onChat,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text("Book"),
                      onPressed: onBook,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}