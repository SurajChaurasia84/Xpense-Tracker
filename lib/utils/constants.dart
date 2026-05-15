import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFFE8F5E9);
  static const Color background = Color(0xFFF8F9FB);
  static const Color textDark = Color(0xFF1A1C1E);
  static const Color textLight = Color(0xFF707784);
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFE53935);
}

class AppCategories {
  static const Map<String, Map<String, dynamic>> expenseCategories = {
    'Housing': {'icon': Icons.home_rounded, 'color': Color(0xFF448AFF)},
    'Food': {'icon': Icons.restaurant_rounded, 'color': Color(0xFF4CAF50)},
    'Transport': {'icon': Icons.directions_car_rounded, 'color': Color(0xFFFF9800)},
    'Shopping': {'icon': Icons.shopping_bag_rounded, 'color': Color(0xFFE91E63)},
    'Entertainment': {'icon': Icons.movie_rounded, 'color': Color(0xFF9C27B0)},
    'Utilities': {'icon': Icons.electric_bolt_rounded, 'color': Color(0xFFFFC107)},
    'Others': {'icon': Icons.grid_view_rounded, 'color': Color(0xFF607D8B)},
  };

  static const Map<String, Map<String, dynamic>> incomeCategories = {
    'Salary': {'icon': Icons.payments_rounded, 'color': Color(0xFF2E7D32)},
    'Freelance': {'icon': Icons.laptop_mac_rounded, 'color': Color(0xFF00ACC1)},
    'Gift': {'icon': Icons.card_giftcard_rounded, 'color': Color(0xFFFF4081)},
    'Bonus': {'icon': Icons.star_rounded, 'color': Color(0xFFFFD600)},
    'Interest': {'icon': Icons.account_balance_rounded, 'color': Color(0xFF7CB342)},
    'Others': {'icon': Icons.add_circle_outline_rounded, 'color': Color(0xFF90A4AE)},
  };

  static Color getCategoryColor(String name) {
    if (expenseCategories.containsKey(name)) return expenseCategories[name]!['color'];
    if (incomeCategories.containsKey(name)) return incomeCategories[name]!['color'];
    return const Color(0xFF607D8B);
  }

  static IconData getCategoryIcon(String name) {
    if (expenseCategories.containsKey(name)) return expenseCategories[name]!['icon'];
    if (incomeCategories.containsKey(name)) return incomeCategories[name]!['icon'];
    return Icons.grid_view_rounded;
  }
}
