import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final TransactionType type;
  final DateTime timestamp;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      category: map['category'] ?? 'Others',
      type: map['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
