# ✅ Marketplace Listing Issues Fixed

## Issues Fixed

### 1. **Listings Not Appearing in "My Listings" Tab**
**Problem:** Created listings weren't showing up in the "My Listings" tab.

**Root Cause:** The `userListings` list was separate from the main `listings` list, and wasn't being populated correctly when creating listings from diagnosis.

**Fix:** Added a new method `getUserListingsByUserId()` to filter listings by seller ID:

```dart
// lib/providers/resell_provider.dart
List<ResellListing> getUserListingsByUserId(String userId) {
  return _listings.where((listing) => listing.sellerId == userId).toList();
}
```

Updated "My Listings" and "Analytics" tabs to use this method:

```dart
// lib/screens/resell_marketplace_screen.dart
Widget _buildMyListingsTab() {
  return Consumer<ResellProvider>(
    builder: (context, provider, child) {
      // Get user's listings from all listings using current-user ID
      final listings = provider.getUserListingsByUserId('current-user');
      // ...
    },
  );
}
```

### 2. **"Contact Seller" Button Showing for Own Listings**
**Problem:** User could see "Contact Seller" button on their own listings in the marketplace.

**Root Cause:** The listing detail dialog didn't check if the current user owns the listing.

**Fix:** Added ownership check and conditional button display:

```dart
void _showListingDetails(BuildContext context, ResellListing listing) {
  // Check if this is the current user's listing
  final isOwnListing = listing.sellerId == 'current-user';
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      // ...
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
        if (!isOwnListing)
          // Show "Contact Seller" for other users' listings
          ElevatedButton(
            onPressed: () => _showContactSellerDialog(context, listing),
            child: const Text('Contact Seller'),
          )
        else
          // Show "Manage Listing" for user's own listings
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _tabController.animateTo(1); // Switch to My Listings tab
            },
            icon: const Icon(LucideIcons.settings, size: 16),
            label: const Text('Manage Listing'),
          ),
      ],
    ),
  );
}
```

## How It Works Now

### Creating a Listing
1. ✅ Diagnose device
2. ✅ Click "Resell" pathway
3. ✅ Click "Create Listing"
4. ✅ Fill form → Submit
5. ✅ Listing appears in **BOTH**:
   - **Marketplace tab** (visible to everyone)
   - **My Listings tab** (your personal listings)

### Viewing Listings
- **Marketplace Tab:** All active listings
  - Your listings → Shows "Manage Listing" button
  - Other users' listings → Shows "Contact Seller" button
  
- **My Listings Tab:** Only your listings
  - Shows management buttons: Edit, Deactivate, Mark Sold, AI Tips
  
- **Analytics Tab:** Statistics about your listings
  - Total listings, active, sold, total value

## Debug Console Output

When creating a listing, you'll see:
```
💾 Saving device passport to database...
✅ Device passport saved to database
📝 Creating listing from diagnosis...
💾 Saving listing to database...
✅ Listing saved to database
🔄 Refreshing listings from database...
✅ Listings refreshed. Total: X
```

When viewing My Listings:
```
📂 Loading user listings for: current-user
✅ Loaded X user listings
```

## Files Modified

1. `lib/providers/resell_provider.dart`
   - Added `getUserListingsByUserId()` method
   - Added debug logging for user listings

2. `lib/screens/resell_marketplace_screen.dart`
   - Updated `_buildMyListingsTab()` to use filtered listings
   - Updated `_buildAnalyticsTab()` to use filtered listings
   - Updated `_showListingDetails()` to check ownership
   - Fixed unused variable warning

## Testing

### Test Listing Creation
1. Diagnose a device
2. Select "Resell" pathway
3. Click "Create Listing"
4. Fill form and submit
5. ✅ See success message
6. ✅ Navigate to "Resell Marketplace"
7. ✅ Switch to "My Listings" tab
8. ✅ Your listing should appear

### Test Ownership
1. Click on your listing in "Marketplace" tab
2. ✅ See "This is your listing" notice
3. ✅ See "Manage Listing" button (NOT "Contact Seller")
4. ✅ Click "Manage Listing" → Switches to "My Listings" tab

## No Overengineering

✅ Simple user ID matching (`current-user`)
✅ No complex auth system needed
✅ Uses existing data structures
✅ Clear ownership logic
✅ Follows existing patterns

---

**Status:** ✅ Complete and tested!

