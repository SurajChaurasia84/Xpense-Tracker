import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser?.uid ?? '';

  // Get user specific transactions collection path
  CollectionReference get _transactionCollection => 
      _db.collection('users').doc(uid).collection('transactions');

  // Get user specific budget document path
  DocumentReference get _budgetDoc => 
      _db.collection('users').doc(uid).collection('settings').doc('budget');

  // --- Transactions ---

  Stream<List<TransactionModel>> getTransactions() {
    return _transactionCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TransactionModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final docRef = _transactionCollection.doc();
    final newTransaction = TransactionModel(
      id: docRef.id,
      title: transaction.title,
      amount: transaction.amount,
      category: transaction.category,
      type: transaction.type,
      timestamp: transaction.timestamp,
    );
    await docRef.set(newTransaction.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionCollection.doc(id).delete();
  }

  // --- Budget ---

  Stream<BudgetModel?> getBudget() {
    return _budgetDoc.snapshots().map((doc) {
      if (doc.exists) {
        return BudgetModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> setBudget(BudgetModel budget) async {
    await _budgetDoc.set(budget.toMap());
  }
}
