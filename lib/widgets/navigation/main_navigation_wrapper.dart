import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../screens/home_screen.dart';
import '../../screens/resell_marketplace_screen.dart';
import '../../screens/upcycling_workspace_screen.dart';
import '../../screens/technician_chatbot_screen.dart';
import '../../screens/devices_overview_screen.dart';
import '../../screens/donation_screen.dart';

class NavigationItem {
  final String label;
  final IconData icon;
  final Widget screen;
  final String route;

  const NavigationItem({
    required this.label,
    required this.icon,
    required this.screen,
    required this.route,
  });
}

class MainNavigationWrapper extends StatefulWidget {
  final int initialIndex;

  const MainNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  late List<NavigationItem> _navigationItems;
  late List<Widget> _screens;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    _navigationItems = [
      NavigationItem(
        label: 'Home',
        icon: Icons.home,
        screen: const HomeScreen(),
        route: '/home',
      ),
      NavigationItem(
        label: 'Resell',
        icon: LucideIcons.shoppingBag,
        screen: const ResellMarketplaceScreen(),
        route: '/resell',
      ),
      NavigationItem(
        label: 'Upcycle',
        icon: LucideIcons.wrench,
        screen: const UpcyclingWorkspaceScreen(),
        route: '/upcycle',
      ),
      NavigationItem(
        label: 'Assistant',
        icon: LucideIcons.messageCircle,
        screen: const TechnicianChatbotScreen(),
        route: '/chatbot',
      ),
      NavigationItem(
        label: 'Devices',
        icon: LucideIcons.smartphone,
        screen: const DevicesOverviewScreen(),
        route: '/devices',
      ),
      NavigationItem(
        label: 'Donation',
        icon: LucideIcons.heart,
        screen: const DonationScreen(),
        route: '/donation',
      ),
    ];

    _screens = _navigationItems.map((item) => item.screen).toList();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.reset();
      _animationController.forward();
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final currentItem = _navigationItems[_selectedIndex];

    return AppBar(
      title: Row(
        children: [
          SizedBox(
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
          const SizedBox(width: 12),
          Text(currentItem.label),
        ],
      ),
      actions: [
        // Different actions based on current screen
        if (_selectedIndex == 0) // Home
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            tooltip: 'Sign Out',
            onPressed: () async {
              // Import UserService here or create method in main_navigation_wrapper
              try {
                // Sign out from OAuth services
                await Future.wait([
                  // Clear any stored session data
                ]);
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                print('Sign out error: $e');
                // Still navigate to login even if sign out fails
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          )
        else if (_selectedIndex == 1) // Resell
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Create Listing',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create listing feature')),
              );
            },
          )
        else if (_selectedIndex == 2) // Upcycle
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Create Project',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create upcycling project')),
              );
            },
          )
        else if (_selectedIndex == 3) // Assistant
          IconButton(
            icon: const Icon(LucideIcons.settings),
            tooltip: 'Settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Assistant settings')),
              );
            },
          )
        else if (_selectedIndex == 4) // Devices
          IconButton(
            icon: const Icon(LucideIcons.plus),
            tooltip: 'Add Device',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Add new device')));
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: FadeTransition(
          key: ValueKey<int>(_selectedIndex),
          opacity: _fadeAnimation,
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: _navigationItems.map((item) {
            final isSelected = _navigationItems.indexOf(item) == _selectedIndex;
            return BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 8.0 : 6.0),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, size: isSelected ? 24 : 20),
              ),
              label: item.label,
            );
          }).toList(),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 12,
          ),
          elevation: 8,
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
