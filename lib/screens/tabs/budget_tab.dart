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

            final allTransactions = txSnapshot.data ?? [];
            final budget = budgetSnapshot.data;

            // Default to Monthly filtering (Current month only)
            final now = DateTime.now();
            final startDate = DateTime(now.year, now.month, 1);

            final transactions = allTransactions.where((tx) => tx.timestamp.isAfter(startDate)).toList();

            // Calculate spending by category
            Map<String, double> spendingByCategory = {};
            for (var tx in transactions) {
              if (tx.type == TransactionType.expense) {
                spendingByCategory[tx.category] = (spendingByCategory[tx.category] ?? 0) + tx.amount;
              }
            }

            // Get all 7 expense categories to show them hamesha
            final allBudgetedCategories = AppCategories.expenseCategories.keys;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  _buildHeader(),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Plan your budget for better financial control',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.black38),
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTotalBudgetSection(budget?.totalBudget ?? 0, currencyFormat, db),
                  const SizedBox(height: 30),
                  Text(
                    'Budget by Categories',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...allBudgetedCategories.map((categoryName) {
                    final spent = spendingByCategory[categoryName] ?? 0.0;
                    final categoryBudget = budget?.categoryBudgets[categoryName] ?? 0.0;
                    return _categoryBudgetItem(categoryName, spent, categoryBudget, currencyFormat);
                  }).toList(),
                  const SizedBox(height: 20),
                  _buildAddCategoryButton(db, budget),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Text(
        'Set Budget',
        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTotalBudgetSection(double amount, NumberFormat format, DatabaseService db) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Budget',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                format.format(amount),
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              GestureDetector(
                onTap: () => _showSetBudgetDialog(context, db, amount),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSetBudgetDialog(BuildContext context, DatabaseService db, double currentBudget) {
    final controller = TextEditingController(text: currentBudget > 0 ? currentBudget.toInt().toString() : '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Set Total Budget', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '₹ ',
            hintText: 'Enter Amount',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newBudget = double.tryParse(controller.text) ?? 0;
              await db.setBudget(BudgetModel(
                totalBudget: newBudget, 
                period: 'Monthly',
                categoryBudgets: {}
              ));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _categoryBudgetItem(String name, double spent, double total, NumberFormat format) {
    final hasBudget = total > 0;
    final percentage = hasBudget ? (spent / total).clamp(0.0, 1.0) : 0.0;
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
                        Text(
                          hasBudget ? format.format(total) : 'No Limit', 
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: hasBudget ? Colors.black : Colors.black38),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: Colors.black12,
                        valueColor: AlwaysStoppedAnimation<Color>(hasBudget ? AppCategories.getCategoryColor(name) : Colors.grey),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          hasBudget ? '${(percentage * 100).toStringAsFixed(0)}%' : '0%', 
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.textLight),
                        ),
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

  Widget _buildAddCategoryButton(DatabaseService db, BudgetModel? currentBudget) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showAddCategoryBudgetDialog(context, db, currentBudget),
        icon: const Icon(Icons.add),
        label: const Text('Add Category Budget'),
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

  void _showAddCategoryBudgetDialog(BuildContext context, DatabaseService db, BudgetModel? currentBudget) {
    String selectedCategory = AppCategories.expenseCategories.keys.first;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Category Budget', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Select Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: AppCategories.expenseCategories.keys.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setDialogState(() => selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text) ?? 0;
                if (amount > 0) {
                  final newCategoryBudgets = Map<String, double>.from(currentBudget?.categoryBudgets ?? {});
                  newCategoryBudgets[selectedCategory] = amount;
                  
                  await db.setBudget(BudgetModel(
                    totalBudget: currentBudget?.totalBudget ?? 0,
                    period: 'Monthly',
                    categoryBudgets: newCategoryBudgets,
                  ));
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
