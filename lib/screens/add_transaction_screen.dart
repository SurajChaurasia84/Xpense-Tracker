import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = ''; // No default category
  TransactionType _selectedType = TransactionType.expense;
  bool _isLoading = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedType == TransactionType.income ? 0 : 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
        ),
        title: Text(
          'Add Transaction',
          style: GoogleFonts.inter(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: _buildTypeSelector(),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _selectedType = index == 0 ? TransactionType.income : TransactionType.expense;
                  _selectedCategory = ''; // Reset category on swipe
                });
              },
              children: [
                _buildFormContent(TransactionType.income),
                _buildFormContent(TransactionType.expense),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: _buildSubmitButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(TransactionType type) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          _buildTextField(
            type == TransactionType.income ? 'Source' : 'Title',
            type == TransactionType.income ? 'Where did you get it from?' : 'What did you spend on?',
            _titleController,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 25),
          _buildTextField('Amount', '0.00', _amountController, keyboardType: TextInputType.number),
          const SizedBox(height: 25),
          _buildCategorySelector(type),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(child: _typeItem('Income', TransactionType.income)),
          Expanded(child: _typeItem('Expense', TransactionType.expense)),
        ],
      ),
    );
  }

  Widget _typeItem(String title, TransactionType type) {
    final isSelected = _selectedType == type;
    final color = type == TransactionType.income ? AppColors.income : AppColors.expense;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          type == TransactionType.income ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType? keyboardType, TextCapitalization textCapitalization = TextCapitalization.none}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            style: GoogleFonts.inter(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: GoogleFonts.inter(color: Colors.black26),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(TransactionType type) {
    final categories = type == TransactionType.income
        ? AppCategories.incomeCategories
        : AppCategories.expenseCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: categories.keys.map((cat) {
            final isSelected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.black12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppCategories.getCategoryIcon(cat),
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isSelected ? Colors.white : AppColors.textLight,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                'Add Transaction',
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty || _selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final db = Provider.of<DatabaseService>(context, listen: false);

    final transaction = TransactionModel(
      id: '',
      title: _titleController.text,
      amount: double.tryParse(_amountController.text) ?? 0,
      category: _selectedCategory,
      type: _selectedType,
      timestamp: DateTime.now(),
    );

    try {
      await db.addTransaction(transaction);
      if (mounted) {
        Navigator.pop(context); // Go back automatically
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}
