class Marketplace {
  final String id;
  final String name;
  final String type; // 'online' or 'physical'
  final String? address;
  final String? contactInfo;
  final String? website;
  final String description;

  const Marketplace({
    required this.id,
    required this.name,
    required this.type,
    this.address,
    this.contactInfo,
    this.website,
    required this.description,
  });

  factory Marketplace.fromJson(Map<String, dynamic> json) {
    return Marketplace(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'],
      contactInfo: json['contactInfo'],
      website: json['website'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'contactInfo': contactInfo,
      'website': website,
      'description': description,
    };
  }
}

// Davao City Marketplaces
const List<Marketplace> davaoMarketplaces = [
  // Online Marketplaces
  Marketplace(
    id: 'facebook_marketplace',
    name: 'Facebook Marketplace',
    type: 'online',
    website: 'https://www.facebook.com/marketplace',
    description: 'Sell to local Davao community on Facebook Marketplace',
  ),
  Marketplace(
    id: 'olx_ph',
    name: 'OLX Philippines',
    type: 'online',
    website: 'https://www.olx.ph',
    description: 'Popular classifieds site in the Philippines',
  ),
  Marketplace(
    id: 'lazada',
    name: 'Lazada',
    type: 'online',
    website: 'https://www.lazada.com.ph',
    description: 'Major e-commerce platform in the Philippines',
  ),
  Marketplace(
    id: 'shopee',
    name: 'Shopee',
    type: 'online',
    website: 'https://shopee.ph',
    description: 'Popular online shopping platform',
  ),

  // Physical Stores in Davao City
  Marketplace(
    id: 'sm_ecoland',
    name: 'SM Ecoland',
    type: 'physical',
    address: 'Ecoland Drive, Matina, Davao City',
    contactInfo: '(082) 297-8888',
    description: 'Major shopping mall in Davao City',
  ),
  Marketplace(
    id: 'abreeza_mall',
    name: 'Abreeza Ayala Mall',
    type: 'physical',
    address: 'J.P. Laurel Avenue, Bajada, Davao City',
    contactInfo: '(082) 221-8888',
    description: 'Premium shopping destination in Davao City',
  ),
  Marketplace(
    id: 'victoria_plaza',
    name: 'Victoria Plaza',
    type: 'physical',
    address: 'C.M. Recto Street, Davao City',
    contactInfo: '(082) 227-8888',
    description: 'Popular shopping center in downtown Davao',
  ),
  Marketplace(
    id: 'gaisano_mall_davao',
    name: 'Gaisano Mall Davao',
    type: 'physical',
    address: 'C.M. Recto Street, Davao City',
    contactInfo: '(082) 227-7777',
    description: 'Local shopping mall chain in Davao',
  ),

  // Local Markets
  Marketplace(
    id: 'bagsakan_center',
    name: 'Bagsakan Center',
    type: 'physical',
    address: 'Bagsakan, Davao City',
    description: 'Major wholesale market for electronics and gadgets',
  ),
  Marketplace(
    id: 'public_market',
    name: 'Davao City Public Market',
    type: 'physical',
    address: 'Rizal Street, Davao City',
    description: 'Local public market for second-hand goods',
  ),

  // Specialty Stores
  Marketplace(
    id: 'computer_stores',
    name: 'Computer Stores (e.g., PC Hub, TechZone)',
    type: 'physical',
    description: 'Specialized computer and electronics stores',
  ),
  Marketplace(
    id: 'pawnshops',
    name: 'Pawnshops & Lending Stores',
    type: 'physical',
    description: 'Local pawnshops that buy and sell electronics',
  ),

  // Other Options
  Marketplace(
    id: 'local_buyers',
    name: 'Direct Local Buyers',
    type: 'other',
    description: 'Sell directly to local buyers through personal networks',
  ),
  Marketplace(
    id: 'online_communities',
    name: 'Davao Online Communities',
    type: 'online',
    description: 'Facebook groups and local online communities',
  ),
];
