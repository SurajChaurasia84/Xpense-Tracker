class BudgetModel {
  final double totalBudget;
  final String period; // Weekly, Monthly, Yearly
  final Map<String, double> categoryBudgets;

  BudgetModel({
    required this.totalBudget,
    required this.period,
    required this.categoryBudgets,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalBudget': totalBudget,
      'period': period,
      'categoryBudgets': categoryBudgets,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      totalBudget: (map['totalBudget'] ?? 0.0).toDouble(),
      period: map['period'] ?? 'Monthly',
      categoryBudgets: Map<String, double>.from(map['categoryBudgets'] ?? {}),
    );
  }
}
