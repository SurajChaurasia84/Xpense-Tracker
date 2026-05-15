import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return StreamBuilder<List<TransactionModel>>(
      stream: db.getTransactions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final transactions = snapshot.data ?? [];
        double totalIncome = 0;
        double totalExpense = 0;

        for (var tx in transactions) {
          if (tx.type == TransactionType.income) {
            totalIncome += tx.amount;
          } else {
            totalExpense += tx.amount;
          }
        }

        double balance = totalIncome - totalExpense;

        // Calculate this month's savings
        final now = DateTime.now();
        final thisMonthStart = DateTime(now.year, now.month, 1);
        double thisMonthSavings = 0;
        for (var tx in transactions) {
          if (tx.timestamp.isAfter(thisMonthStart)) {
            if (tx.type == TransactionType.income) {
              thisMonthSavings += tx.amount;
            } else {
              thisMonthSavings -= tx.amount;
            }
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildBalanceCard(balance, thisMonthSavings, currencyFormat),
              const SizedBox(height: 20),
              _buildQuickSummary(totalIncome, totalExpense, currencyFormat),
              const SizedBox(height: 30),
              _buildSpendingOverview(transactions, totalExpense, currencyFormat),
              const SizedBox(height: 30),
              _buildRecentTransactions(transactions, currencyFormat),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'User';
    final firstName = displayName.split(' ')[0];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $firstName 👋',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            Text(
              'Take control of your money',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(Icons.notifications_outlined),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(double balance, double monthlySavings, NumberFormat format) {
    final isPositive = monthlySavings >= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2E7D32),
            const Color(0xFF43A047),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Balance',
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              const Icon(Icons.visibility_outlined, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            format.format(balance),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 12,
                ),
                const SizedBox(width: 4),
                Text(
                  '${format.format(monthlySavings.abs())} this month',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary(double income, double expense, NumberFormat format) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard('Income', income, AppColors.income, Icons.south_west),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _summaryCard('Expenses', expense, AppColors.expense, Icons.north_east),
        ),
      ],
    );
  }

  Widget _summaryCard(String title, double amount, Color color, IconData icon) {
    final format = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            format.format(amount),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingOverview(List<TransactionModel> transactions, double totalExpense, NumberFormat format) {
    Map<String, double> categoryData = {};
    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        categoryData[tx.category] = (categoryData[tx.category] ?? 0) + tx.amount;
      }
    }

    List<PieChartSectionData> sections = [];
    categoryData.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          value: value,
          color: AppCategories.getCategoryColor(key),
          radius: 20,
          showTitle: false,
        ),
      );
    });

    if (sections.isEmpty) {
      sections.add(PieChartSectionData(value: 1, color: Colors.grey.shade300, radius: 20, showTitle: false));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spending Overview',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'This Month',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: sections,
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        format.format(totalExpense),
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total Expenses',
                        style: GoogleFonts.inter(fontSize: 8, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: categoryData.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppCategories.getCategoryColor(entry.key),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
                        ),
                        const Spacer(),
                        Text(
                          '${((entry.value / totalExpense) * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(List<TransactionModel> transactions, NumberFormat format) {
    final recent = transactions.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'View all',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...recent.map((tx) => _transactionItem(tx, format)),
      ],
    );
  }

  Widget _transactionItem(TransactionModel tx, NumberFormat format) {
    final isIncome = tx.type == TransactionType.income;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppCategories.getCategoryColor(tx.category).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              AppCategories.getCategoryIcon(tx.category),
              color: AppCategories.getCategoryColor(tx.category),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  tx.category,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'} ${format.format(tx.amount)}',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isIncome ? AppColors.income : AppColors.textDark,
                ),
              ),
              Text(
                'Today', // In real app, format timestamp
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
