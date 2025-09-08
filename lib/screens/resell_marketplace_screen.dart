import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../models/resell_listing.dart';
import '../providers/resell_provider.dart';

class ResellMarketplaceScreen extends StatefulWidget {
  const ResellMarketplaceScreen({super.key});

  @override
  State<ResellMarketplaceScreen> createState() =>
      _ResellMarketplaceScreenState();
}

class _ResellMarketplaceScreenState extends State<ResellMarketplaceScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResellProvider>().loadListings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              child: Image.asset(
                'assets/images/Ayo-ayo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(LucideIcons.leaf, size: 20, color: Colors.blue);
                },
              ),
            ),
            const SizedBox(width: 8),
            const Text('Resell Hub'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.plus),
            onPressed: () => _showCreateListingDialog(context),
            tooltip: 'Create Listing',
          ),
          IconButton(
            icon: Icon(LucideIcons.settings),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Marketplace', icon: Icon(LucideIcons.shoppingBag)),
            Tab(text: 'My Listings', icon: Icon(LucideIcons.package)),
            Tab(text: 'Analytics', icon: Icon(LucideIcons.trendingUp)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search listings...',
                prefixIcon: const Icon(LucideIcons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ResellProvider>().searchListings('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                context.read<ResellProvider>().searchListings(value);
              },
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMarketplaceTab(),
                _buildMyListingsTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListingDialog(context),
        child: const Icon(LucideIcons.plus),
        tooltip: 'Create New Listing',
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    return Consumer<ResellProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final listings = provider.activeListings;

        if (listings.isEmpty) {
          return _buildEmptyState(
            'No active listings',
            'Be the first to list your device for sale!',
            LucideIcons.shoppingBag,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadListings(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              return _buildListingCard(listings[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyListingsTab() {
    return Consumer<ResellProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final listings = provider.userListings;

        if (listings.isEmpty) {
          return _buildEmptyState(
            'No listings yet',
            'Create your first listing to start selling!',
            LucideIcons.package,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            return _buildMyListingCard(listings[index]);
          },
        );
      },
    );
  }

  Widget _buildAnalyticsTab() {
    return Consumer<ResellProvider>(
      builder: (context, provider, child) {
        final listings = provider.userListings;
        final activeListings = listings
            .where((l) => l.status == ListingStatus.active)
            .length;
        final soldListings = listings
            .where((l) => l.status == ListingStatus.sold)
            .length;
        final totalValue = listings.fold<double>(
          0,
          (sum, l) => sum + l.askingPrice,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnalyticsCard(
                'Total Listings',
                listings.length.toString(),
                LucideIcons.package,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard(
                'Active Listings',
                activeListings.toString(),
                LucideIcons.shoppingBag,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard(
                'Sold Items',
                soldListings.toString(),
                LucideIcons.check,
                Colors.purple,
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard(
                'Total Value',
                '₦${totalValue.toStringAsFixed(0)}',
                LucideIcons.dollarSign,
                Colors.orange,
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...listings.take(5).map((listing) => _buildActivityItem(listing)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListingCard(ResellListing listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showListingDetails(context, listing),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getConditionColor(listing.condition),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      listing.condition.toString().split('.').last,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${listing.devicePassport.deviceModel} • ${listing.devicePassport.manufacturer}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₦${listing.askingPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    '${listing.daysActive} days ago',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
              if (listing.aiSuggestedPrice != null &&
                  listing.priceDifference.abs() > 1000) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: listing.isPriceOptimal
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: listing.isPriceOptimal
                          ? Colors.green[200]!
                          : Colors.orange[200]!,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        listing.isPriceOptimal
                            ? LucideIcons.trendingUp
                            : LucideIcons.triangleAlert,
                        size: 16,
                        color: listing.isPriceOptimal
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        listing.isPriceOptimal
                            ? 'Price optimized by AI'
                            : 'AI suggests ₦${listing.aiSuggestedPrice!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: listing.isPriceOptimal
                              ? Colors.green[700]
                              : Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyListingCard(ResellListing listing) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showMyListingDetails(context, listing),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(listing.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      listing.status.toString().split('.').last,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₦${listing.askingPrice.toStringAsFixed(0)} • ${listing.daysActive} days active',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showSalesTips(context, listing),
                    icon: const Icon(LucideIcons.lightbulb, size: 16),
                    label: const Text('AI Tips'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showEditListingDialog(context, listing),
                    icon: Icon(LucideIcons.pencil, size: 16),
                    label: const Text('Edit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(ResellListing listing) {
    return ListTile(
      leading: Icon(
        listing.status == ListingStatus.sold
            ? LucideIcons.check
            : LucideIcons.package,
        color: listing.status == ListingStatus.sold
            ? Colors.green
            : Colors.blue,
      ),
      title: Text(listing.title),
      subtitle: Text(
        '${listing.status.toString().split('.').last} • ₦${listing.askingPrice.toStringAsFixed(0)}',
      ),
      trailing: Text(
        '${listing.daysActive}d ago',
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateListingDialog(context),
            icon: const Icon(LucideIcons.plus),
            label: const Text('Create First Listing'),
          ),
        ],
      ),
    );
  }

  Color _getConditionColor(ConditionGrade condition) {
    switch (condition) {
      case ConditionGrade.excellent:
        return Colors.green;
      case ConditionGrade.good:
        return Colors.blue;
      case ConditionGrade.fair:
        return Colors.orange;
      case ConditionGrade.poor:
        return Colors.red;
      case ConditionGrade.damaged:
        return Colors.grey;
    }
  }

  Color _getStatusColor(ListingStatus status) {
    switch (status) {
      case ListingStatus.active:
        return Colors.green;
      case ListingStatus.sold:
        return Colors.purple;
      case ListingStatus.draft:
        return Colors.grey;
      case ListingStatus.expired:
        return Colors.orange;
      case ListingStatus.cancelled:
        return Colors.red;
    }
  }

  void _showCreateListingDialog(BuildContext context) {
    // Implementation for creating new listing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Listing'),
        content: const Text('Listing creation form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showListingDetails(BuildContext context, ResellListing listing) {
    // Implementation for showing listing details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listing.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ₦${listing.askingPrice.toStringAsFixed(0)}'),
            Text('Condition: ${listing.condition.toString().split('.').last}'),
            Text('Device: ${listing.devicePassport.deviceModel}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement contact seller functionality
              Navigator.of(context).pop();
            },
            child: const Text('Contact Seller'),
          ),
        ],
      ),
    );
  }

  void _showMyListingDetails(BuildContext context, ResellListing listing) {
    // Implementation for showing user's listing details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listing.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ₦${listing.askingPrice.toStringAsFixed(0)}'),
            Text('Status: ${listing.status.toString().split('.').last}'),
            Text('Views: ${listing.daysActive * 10}'), // Mock data
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSalesTips(BuildContext context, ResellListing listing) async {
    final provider = context.read<ResellProvider>();
    final tips = await provider.getSalesTips(listing.id);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Sales Tips'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tips.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[100],
                  child: Text('${index + 1}'),
                ),
                title: Text(tips[index]),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditListingDialog(BuildContext context, ResellListing listing) {
    // Implementation for editing listing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Listing'),
        content: const Text('Listing edit form will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    // Implementation for filtering listings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Listings'),
        content: const Text('Filter options will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
