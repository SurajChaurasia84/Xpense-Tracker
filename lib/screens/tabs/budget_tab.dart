import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';

class BudgetTab extends StatefulWidget {
  const BudgetTab({super.key});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  String _selectedPeriod = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return StreamBuilder<List<TransactionModel>>(
      stream: db.getTransactions(),
      builder: (context, txSnapshot) {
        return StreamBuilder<BudgetModel?>(
          stream: db.getBudget(),
          builder: (context, budgetSnapshot) {
            if (txSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final transactions = txSnapshot.data ?? [];
            final budget = budgetSnapshot.data;

            // Calculate spending by category
            Map<String, double> spendingByCategory = {};
            for (var tx in transactions) {
              if (tx.type == TransactionType.expense) {
                spendingByCategory[tx.category] = (spendingByCategory[tx.category] ?? 0) + tx.amount;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildHeader(),
                  const SizedBox(height: 20),
                  _buildPeriodSelector(),
                  const SizedBox(height: 30),
                  _buildTotalBudgetSection(budget?.totalBudget ?? 0, currencyFormat),
                  const SizedBox(height: 30),
                  Text(
                    'Budget by Categories',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...spendingByCategory.entries.map((entry) {
                    final categoryBudget = budget?.categoryBudgets[entry.key] ?? entry.value * 1.2; // fallback
                    return _categoryBudgetItem(entry.key, entry.value, categoryBudget, currencyFormat);
                  }).toList(),
                  const SizedBox(height: 20),
                  _buildAddCategoryButton(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.arrow_back_ios_new, size: 20),
        Expanded(
          child: Center(
            child: Text(
              'Set Budget',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Period',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['Weekly', 'Monthly', 'Yearly'].map((period) {
            final isSelected = _selectedPeriod == period;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriod = period),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.black12),
                  ),
                  child: Center(
                    child: Text(
                      period,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isSelected ? Colors.white : AppColors.textLight,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTotalBudgetSection(double amount, NumberFormat format) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Budget',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              format.format(amount),
              style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.edit_outlined, color: AppColors.textLight, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _categoryBudgetItem(String name, double spent, double total, NumberFormat format) {
    final percentage = (spent / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppCategories.getCategoryColor(name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(AppCategories.getCategoryIcon(name), color: AppCategories.getCategoryColor(name), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(format.format(total), style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(AppCategories.getCategoryColor(name)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${(percentage * 100).toStringAsFixed(0)}%', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight)),
                        Text('Spent ${format.format(spent)}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}
