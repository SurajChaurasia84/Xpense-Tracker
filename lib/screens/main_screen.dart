import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Placeholder screens
  final List<Widget> _screens = [
    const Center(child: Text('Home Screen')),
    const Center(child: Text('Transactions Screen')),
    const Center(child: Text('Add Transaction Screen')), // Placeholder for FAB
    const Center(child: Text('Budget Screen')),
    const Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF2E7D32);

    return Scaffold(
      body: _screens[_currentIndex],
      
      // The central Floating Action Button (the "+" icon)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for adding new transaction
        },
        backgroundColor: themeColor,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Bottom Navigation Bar matching the image
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side icons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _navItem(Icons.home_filled, 'Home', 0),
                  _navItem(Icons.swap_horiz_rounded, 'Transactions', 1),
                ],
              ),
              
              // Right side icons
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _navItem(Icons.account_balance_wallet_rounded, 'Budget', 3),
                  _navItem(Icons.person_outline_rounded, 'Profile', 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build navigation items
  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF2E7D32) : Colors.grey;

    return MaterialButton(
      minWidth: 80,
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
