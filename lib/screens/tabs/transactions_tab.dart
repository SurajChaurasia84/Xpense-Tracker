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

class _TransactionsTabState extends State<TransactionsTab> with SingleTickerProviderStateMixin {
  int _selectedFilter = 0; // 0: All, 1: Income, 2: Expense
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedFilter = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = snapshot.data ?? [];

              return TabBarView(
                controller: _tabController,
                children: [
                  TransactionListView(
                    transactions: transactions,
                    filterIndex: 0,
                    searchQuery: _searchQuery,
                    format: currencyFormat,
                  ),
                  TransactionListView(
                    transactions: transactions,
                    filterIndex: 1,
                    searchQuery: _searchQuery,
                    format: currencyFormat,
                  ),
                  TransactionListView(
                    transactions: transactions,
                    filterIndex: 2,
                    searchQuery: _searchQuery,
                    format: currencyFormat,
                  ),
                ],
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
          Navigator.canPop(context)
              ? IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                )
              : const SizedBox(width: 48),
          Text(
            'Transactions',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48), // To keep title centered
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
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final screenWidth = MediaQuery.of(context).size.width;
    final tabWidth = screenWidth / 3;
    final indicatorWidth = tabWidth - 30;

    return Column(
      children: [
        Stack(
          children: [
            AnimatedBuilder(
              animation: _tabController.animation!,
              builder: (context, child) {
                return Row(
                  children: [
                    _filterItem('All', 0),
                    _filterItem('Income', 1),
                    _filterItem('Expense', 2),
                  ],
                );
              },
            ),
            AnimatedBuilder(
              animation: _tabController.animation!,
              builder: (context, child) {
                return Positioned(
                  bottom: 0,
                  left: (_tabController.animation!.value * tabWidth) + (tabWidth - indicatorWidth) / 2,
                  child: Container(
                    height: 3,
                    width: indicatorWidth,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _filterItem(String title, int index) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _tabController.animateTo(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: AnimatedBuilder(
              animation: _tabController.animation!,
              builder: (context, child) {
                final lerp = (1.0 - (_tabController.animation!.value - index).abs()).clamp(0.0, 1.0);
                final color = Color.lerp(AppColors.textLight, AppColors.textDark, lerp);
                final fontWeight = lerp > 0.5 ? FontWeight.w600 : FontWeight.w500;
                
                return Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: fontWeight,
                    color: color,
                  ),
                );
              },
            ),
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

class TransactionListView extends StatefulWidget {
  final List<TransactionModel> transactions;
  final int filterIndex;
  final String searchQuery;
  final NumberFormat format;

  const TransactionListView({
    super.key,
    required this.transactions,
    required this.filterIndex,
    required this.searchQuery,
    required this.format,
  });

  @override
  State<TransactionListView> createState() => _TransactionListViewState();
}

class _TransactionListViewState extends State<TransactionListView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var filtered = widget.transactions;
    if (widget.filterIndex == 1) {
      filtered = widget.transactions.where((t) => t.type == TransactionType.income).toList();
    } else if (widget.filterIndex == 2) {
      filtered = widget.transactions.where((t) => t.type == TransactionType.expense).toList();
    }

    if (widget.searchQuery.isNotEmpty) {
      filtered = filtered.where((t) => t.title.toLowerCase().contains(widget.searchQuery.toLowerCase())).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No transactions found',
          style: GoogleFonts.inter(color: AppColors.textLight),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final tx = filtered[index];
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
                    '${isIncome ? '+' : '-'} ${widget.format.format(tx.amount)}',
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
      },
    );
  }
}
