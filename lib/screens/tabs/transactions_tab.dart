import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';

class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  int _selectedFilter = 0; // 0: All, 1: Income, 2: Expense
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Column(
      children: [
        const SizedBox(height: 50),
        _buildHeader(),
        _buildSearchAndFilter(),
        _buildFilterTabs(),
        Expanded(
          child: StreamBuilder<List<TransactionModel>>(
            stream: db.getTransactions(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var transactions = snapshot.data ?? [];

              // Filter by type
              if (_selectedFilter == 1) {
                transactions = transactions.where((t) => t.type == TransactionType.income).toList();
              } else if (_selectedFilter == 2) {
                transactions = transactions.where((t) => t.type == TransactionType.expense).toList();
              }

              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                transactions = transactions
                    .where((t) => t.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                    .toList();
              }

              if (transactions.isEmpty) {
                return Center(
                  child: Text(
                    'No transactions found',
                    style: GoogleFonts.inter(color: AppColors.textLight),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  // Basic grouping logic for demo. Real app would group by date.
                  return _transactionItem(tx, currencyFormat);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.arrow_back_ios_new, size: 20),
          Text(
            'Transactions',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20), // Placeholder for balance
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search transactions',
                  hintStyle: GoogleFonts.inter(color: AppColors.textLight, fontSize: 14),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: AppColors.textLight, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
              ],
            ),
            child: const Icon(Icons.tune, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _filterItem('All', 0),
          _filterItem('Income', 1),
          _filterItem('Expense', 2),
        ],
      ),
    );
  }

  Widget _filterItem(String title, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _transactionItem(TransactionModel tx, NumberFormat format) {
    final isIncome = tx.type == TransactionType.income;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
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
                DateFormat('d MMM').format(tx.timestamp),
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
