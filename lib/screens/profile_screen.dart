import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../utils/constants.dart';
import '../services/security_service.dart';
import 'personal_info_screen.dart';
import 'security_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final db = Provider.of<DatabaseService>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final themeColor = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: db.getUserProfile(),
        builder: (context, profileSnapshot) {
          final profileData = profileSnapshot.data;
          final customName = profileData?['displayName'];
          final customPhone = profileData?['phoneNumber'];
          
          final displayName = customName ?? user?.displayName ?? 'User Name';

          return StreamBuilder<List<TransactionModel>>(
            stream: db.getTransactions(),
            builder: (context, txSnapshot) {
              return StreamBuilder<BudgetModel?>(
                stream: db.getBudget(),
                builder: (context, budgetSnapshot) {
                  final transactions = txSnapshot.data ?? [];
                  final budget = budgetSnapshot.data;

                  double totalIncome = 0;
                  double totalExpense = 0;
                  for (var tx in transactions) {
                    if (tx.type == TransactionType.income) {
                      totalIncome += tx.amount;
                    } else {
                      totalExpense += tx.amount;
                    }
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        
                        // Profile Header
                        Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: themeColor.withOpacity(0.1),
                              ),
                              child: ClipOval(
                                child: user?.photoURL != null
                                    ? CachedNetworkImage(
                                        imageUrl: user!.photoURL!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Icon(Icons.person, size: 50, color: themeColor),
                                        errorWidget: (context, url, error) => Icon(Icons.person, size: 50, color: themeColor),
                                      )
                                    : Icon(Icons.person, size: 50, color: themeColor),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              displayName,
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              user?.email ?? 'user@example.com',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.black45,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Stats Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              _buildStatCard('Total Income', currencyFormat.format(totalIncome), Icons.arrow_upward, AppColors.income),
                              const SizedBox(width: 15),
                              _buildStatCard('Total Expense', currencyFormat.format(totalExpense), Icons.arrow_downward, AppColors.expense),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Settings List
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              _buildSettingsItem(
                                Icons.person_outline, 
                                'Personal Info', 
                                'Name, Phone',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PersonalInfoScreen(
                                      currentName: displayName,
                                      currentPhone: customPhone ?? '',
                                    ),
                                  ),
                                ),
                              ),
                              _buildSettingsItem(
                                Icons.security_rounded, 
                                'Security', 
                                'PIN, Fingerprint',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
                                ),
                              ),
                              const SizedBox(height: 20),
                              
                              // Logout Button
                              GestureDetector(
                                onTap: () => FirebaseAuth.instance.signOut(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.red.withOpacity(0.1)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.logout_rounded, color: Colors.red),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Sign Out',
                                        style: GoogleFonts.inter(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textLight),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.black54, size: 22),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
