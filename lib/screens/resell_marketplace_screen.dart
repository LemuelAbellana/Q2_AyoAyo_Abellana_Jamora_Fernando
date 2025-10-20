import 'package:ayoayo/screens/create_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../models/resell_listing.dart';
import '../models/marketplace.dart';
import '../models/device_diagnosis.dart';
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

  // Filter states
  ListingCategory? _selectedCategory;
  ConditionGrade? _selectedCondition;
  RangeValues _priceRange = const RangeValues(0, 50000);
  String? _selectedLocation;
  bool _showFilters = false;

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
      body: Column(
        children: [
          // Add the TabBar to the body
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Marketplace', icon: Icon(LucideIcons.shoppingBag)),
              Tab(text: 'My Listings', icon: Icon(LucideIcons.package)),
              Tab(text: 'Analytics', icon: Icon(LucideIcons.trendingUp)),
            ],
          ),
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search listings...',
                    prefixIcon: const Icon(LucideIcons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(LucideIcons.x),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          ),
                        IconButton(
                          icon: Icon(
                            _showFilters
                                ? Icons.filter_list_off
                                : Icons.filter_list,
                          ),
                          onPressed: () {
                            setState(() {
                              _showFilters = !_showFilters;
                            });
                          },
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  onChanged: (value) {
                    _applyFilters();
                  },
                ),

                // Filters (expandable)
                if (_showFilters) ...[
                  const SizedBox(height: 16),
                  _buildFiltersSection(),
                ],
              ],
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
        tooltip: 'Create New Listing',
        child: const Icon(LucideIcons.plus),
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    return Consumer<ResellProvider>(
      builder: (context, provider, child) {
        // Show error state
        if (provider.errorMessage != null && provider.listings.isEmpty) {
          return _buildErrorState(
            provider.errorMessage!,
            provider.loadListings,
          );
        }

        if (provider.isLoading && provider.listings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final allListings = provider.activeListings;
        final filteredListings = _getFilteredListings(allListings);

        if (allListings.isEmpty) {
          return _buildEmptyState(
            'No active listings',
            'Be the first to list your device for sale!',
            LucideIcons.shoppingBag,
          );
        }

        if (filteredListings.isEmpty) {
          return _buildEmptyState(
            'No listings match your filters',
            'Try adjusting your search or filters.',
            LucideIcons.searchX,
          );
        }

        return Column(
          children: [
            // Error banner (if there's an error but we have cached data)
            if (provider.errorMessage != null)
              Container(
                color: Colors.orange[50],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Unable to refresh listings: ${provider.errorMessage}',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => provider.loadListings(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${filteredListings.length} listing${filteredListings.length == 1 ? '' : 's'} found',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  // Sort options could be added here
                ],
              ),
            ),

            // Listings list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.loadListings(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredListings.length,
                  itemBuilder: (context, index) {
                    return _buildListingCard(filteredListings[index]);
                  },
                ),
              ),
            ),
          ],
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

        // Get user's listings from all listings using current-user ID
        final listings = provider.getUserListingsByUserId('current-user');

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
        // Get user's listings from all listings
        final listings = provider.getUserListingsByUserId('current-user');
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
                '₱${totalValue.toStringAsFixed(0)}',
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
      elevation: 2,
      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showListingDetails(context, listing),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and condition badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      listing.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getConditionColor(
                        listing.condition,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getConditionColor(
                          listing.condition,
                        ).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getConditionDisplayName(listing.condition),
                      style: TextStyle(
                        color: _getConditionColor(listing.condition),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Device info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.smartphone,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${listing.devicePassport.deviceModel} • ${listing.devicePassport.manufacturer}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Location and time
              Row(
                children: [
                  if (listing.location != null &&
                      listing.location!.isNotEmpty) ...[
                    Icon(LucideIcons.mapPin, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        listing.location!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(LucideIcons.clock, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '${listing.daysActive} ${listing.daysActive == 1 ? 'day' : 'days'} ago',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Price section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₱${listing.askingPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (listing.aiSuggestedPrice != null) ...[
                          Text(
                            'AI suggests: ₱${listing.aiSuggestedPrice!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (listing.aiSuggestedPrice != null &&
                        listing.priceDifference.abs() > 1000) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: listing.isPriceOptimal
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: listing.isPriceOptimal
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              listing.isPriceOptimal
                                  ? LucideIcons.trendingUp
                                  : LucideIcons.triangleAlert,
                              size: 14,
                              color: listing.isPriceOptimal
                                  ? Colors.green[700]
                                  : Colors.orange[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              listing.isPriceOptimal ? 'Optimal' : 'Adjust',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
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

              const SizedBox(height: 12),

              // Battery health indicator
              Row(
                children: [
                  Icon(
                    LucideIcons.cpu,
                    size: 16,
                    color: _getHardwareColor(
                      listing
                          .devicePassport
                          .lastDiagnosis
                          .deviceHealth
                          .hardwareCondition,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${listing.devicePassport.lastDiagnosis.deviceHealth.hardwareCondition.name} Hardware',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Icon(LucideIcons.eye, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    '${(listing.daysActive * 8 + 15).toStringAsFixed(0)} views',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getHardwareColor(HardwareCondition condition) {
    switch (condition) {
      case HardwareCondition.excellent:
      case HardwareCondition.good:
        return Colors.green;
      case HardwareCondition.fair:
        return Colors.orange;
      case HardwareCondition.poor:
      case HardwareCondition.damaged:
        return Colors.red;
      case HardwareCondition.unknown:
        return Colors.grey;
    }
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
                '₱${listing.askingPrice.toStringAsFixed(0)} • ${listing.daysActive} days active',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Status management buttons
                    if (listing.status == ListingStatus.draft)
                      TextButton.icon(
                        onPressed: () => _activateListing(context, listing),
                        icon: const Icon(LucideIcons.play, size: 16),
                        label: const Text('Activate'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      )
                    else if (listing.status == ListingStatus.active)
                      TextButton.icon(
                        onPressed: () => _deactivateListing(context, listing),
                        icon: const Icon(LucideIcons.pause, size: 16),
                        label: const Text('Deactivate'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),

                    const SizedBox(width: 8),

                    TextButton.icon(
                      onPressed: () => _showSalesTips(context, listing),
                      icon: const Icon(LucideIcons.lightbulb, size: 16),
                      label: const Text('AI Tips'),
                    ),

                    const SizedBox(width: 8),

                    TextButton.icon(
                      onPressed: () => _markAsSold(context, listing),
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: const Text('Mark Sold'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),

                    const SizedBox(width: 8),

                    TextButton.icon(
                      onPressed: () => _showEditListingDialog(context, listing),
                      icon: const Icon(LucideIcons.pencil, size: 16),
                      label: const Text('Edit'),
                    ),
                  ],
                ),
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
                color: color.withValues(alpha: 0.1),
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
        '${listing.status.toString().split('.').last} • ₱${listing.askingPrice.toStringAsFixed(0)}',
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

  Widget _buildErrorState(
    String errorMessage,
    Future<void> Function() retryAction,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.arrowLeft),
                  label: const Text('Go Back'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: retryAction,
                  icon: const Icon(LucideIcons.refreshCw),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
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
    // For now, navigate to full create listing screen
    // In a future update, we could check for recent diagnosis results and pre-fill
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateListingScreen()),
    );
  }

  void _showListingDetails(BuildContext context, ResellListing listing) {
    // Check if this is the current user's listing
    final isOwnListing = listing.sellerId == 'current-user';

    // Implementation for showing listing details
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(listing.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ₱${listing.askingPrice.toStringAsFixed(0)}'),
            Text('Condition: ${listing.condition.toString().split('.').last}'),
            Text('Device: ${listing.devicePassport.deviceModel}'),
            if (isOwnListing) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is your listing',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          if (!isOwnListing)
            ElevatedButton(
              onPressed: () => _showContactSellerDialog(context, listing),
              child: const Text('Contact Seller'),
            )
          else
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Switch to My Listings tab
                _tabController.animateTo(1);
              },
              icon: const Icon(LucideIcons.settings, size: 16),
              label: const Text('Manage Listing'),
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
            Text('Price: ₱${listing.askingPrice.toStringAsFixed(0)}'),
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
    final titleController = TextEditingController(text: listing.title);
    final descriptionController = TextEditingController(
      text: listing.description,
    );
    final priceController = TextEditingController(
      text: listing.askingPrice.toStringAsFixed(0),
    );
    ConditionGrade selectedCondition = listing.condition;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Listing'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device info (read-only)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.smartphone,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          listing.devicePassport.deviceModel,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Listing Title',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(LucideIcons.text),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(LucideIcons.fileText),
                  ),
                ),
                const SizedBox(height: 12),

                // Price
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Asking Price (₱)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(LucideIcons.dollarSign),
                    prefixText: '₱ ',
                    helperText: listing.aiSuggestedPrice != null
                        ? 'AI suggests: ₱${listing.aiSuggestedPrice!.toStringAsFixed(0)}'
                        : null,
                  ),
                ),
                const SizedBox(height: 12),

                // Condition
                DropdownButtonFormField<ConditionGrade>(
                  value: selectedCondition,
                  decoration: const InputDecoration(
                    labelText: 'Device Condition',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(LucideIcons.info),
                  ),
                  items: ConditionGrade.values.map((grade) {
                    return DropdownMenuItem(
                      value: grade,
                      child: Text(_getConditionDisplayName(grade)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedCondition = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                titleController.dispose();
                descriptionController.dispose();
                priceController.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final price = double.tryParse(priceController.text);
                if (price == null || titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields correctly'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final provider = context.read<ResellProvider>();
                final success = await provider.updateListing(
                  listing.id,
                  title: titleController.text,
                  description: descriptionController.text,
                  askingPrice: price,
                  condition: selectedCondition,
                );

                titleController.dispose();
                descriptionController.dispose();
                priceController.dispose();

                if (success) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Listing updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.errorMessage ?? 'Failed to update listing',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(LucideIcons.check, size: 16),
              label: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activateListing(
    BuildContext context,
    ResellListing listing,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Listing'),
        content: const Text(
          'Are you sure you want to activate this listing? It will be visible to buyers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Activate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<ResellProvider>().activateListing(
        listing.id,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing activated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to activate listing'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deactivateListing(
    BuildContext context,
    ResellListing listing,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Listing'),
        content: const Text(
          'Are you sure you want to deactivate this listing? It will no longer be visible to buyers.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<ResellProvider>().deactivateListing(
        listing.id,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing deactivated successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to deactivate listing'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _markAsSold(BuildContext context, ResellListing listing) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Sold'),
        content: const Text(
          'Are you sure you want to mark this listing as sold? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Mark as Sold'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await context.read<ResellProvider>().markListingAsSold(
        listing.id,
      );
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing marked as sold!'),
            backgroundColor: Colors.blue,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to mark listing as sold'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showContactSellerDialog(BuildContext context, ResellListing listing) {
    final messageController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(LucideIcons.messageCircle, size: 24),
            const SizedBox(width: 8),
            const Text('Contact Seller'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About this listing',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                listing.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '₱${listing.askingPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Your contact information',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '+63 9XX XXX XXXX',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message',
                  hintText:
                      'Hi, I\'m interested in your ${listing.devicePassport.deviceModel}. Is it still available?',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your message will be sent to the seller. Please be respectful and provide accurate contact information.',
                        style: TextStyle(color: Colors.blue[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (phoneController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide your phone number'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // In a real app, this would send the message to the seller
              // For now, we'll just show a success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message sent to seller successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(LucideIcons.send, size: 16),
            label: const Text('Send Message'),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 8),
              Text(
                'Filters',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Filter
          Text(
            'Category',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ListingCategory.values.map((category) {
              return FilterChip(
                label: Text(_getCategoryDisplayName(category)),
                selected: _selectedCategory == category,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = selected ? category : null;
                  });
                  _applyFilters();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Condition Filter
          Text(
            'Condition',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ConditionGrade.values.map((condition) {
              return FilterChip(
                label: Text(_getConditionDisplayName(condition)),
                selected: _selectedCondition == condition,
                onSelected: (selected) {
                  setState(() {
                    _selectedCondition = selected ? condition : null;
                  });
                  _applyFilters();
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Price Range Filter
          Text(
            'Price Range: ₱${_priceRange.start.round()} - ₱${_priceRange.end.round()}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 50000,
            divisions: 50,
            labels: RangeLabels(
              '₱${_priceRange.start.round()}',
              '₱${_priceRange.end.round()}',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
              _applyFilters();
            },
          ),

          const SizedBox(height: 16),

          // Location Filter
          Text(
            'Location',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            decoration: InputDecoration(
              hintText: 'All locations',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All locations'),
              ),
              ...davaoMarketplaces.map((marketplace) {
                return DropdownMenuItem<String>(
                  value: marketplace.name,
                  child: Text(marketplace.name),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedLocation = value;
              });
              _applyFilters();
            },
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    // Trigger a rebuild to apply filters
    setState(() {});
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedCondition = null;
      _priceRange = const RangeValues(0, 50000);
      _selectedLocation = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  List<ResellListing> _getFilteredListings(List<ResellListing> listings) {
    return listings.where((listing) {
      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchText = _searchController.text.toLowerCase();
        if (!listing.title.toLowerCase().contains(searchText) &&
            !listing.description.toLowerCase().contains(searchText) &&
            !listing.devicePassport.deviceModel.toLowerCase().contains(
              searchText,
            )) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && listing.category != _selectedCategory) {
        return false;
      }

      // Condition filter
      if (_selectedCondition != null &&
          listing.condition != _selectedCondition) {
        return false;
      }

      // Price range filter
      if (listing.askingPrice < _priceRange.start ||
          listing.askingPrice > _priceRange.end) {
        return false;
      }

      // Location filter
      if (_selectedLocation != null && listing.location != _selectedLocation) {
        return false;
      }

      return true;
    }).toList();
  }

  String _getCategoryDisplayName(ListingCategory category) {
    switch (category) {
      case ListingCategory.smartphone:
        return 'Smartphone';
      case ListingCategory.tablet:
        return 'Tablet';
      case ListingCategory.laptop:
        return 'Laptop';
      case ListingCategory.wearable:
        return 'Wearable';
      case ListingCategory.accessory:
        return 'Accessory';
      case ListingCategory.other:
        return 'Other';
    }
  }

  String _getConditionDisplayName(ConditionGrade condition) {
    switch (condition) {
      case ConditionGrade.excellent:
        return 'Excellent';
      case ConditionGrade.good:
        return 'Good';
      case ConditionGrade.fair:
        return 'Fair';
      case ConditionGrade.poor:
        return 'Poor';
      case ConditionGrade.damaged:
        return 'Damaged';
    }
  }
}
