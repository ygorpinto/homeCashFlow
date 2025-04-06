import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import 'database_service.dart';
import 'web_storage_service.dart';

class TransactionProvider with ChangeNotifier {
  late final dynamic _storageService;
  List<FinancialTransaction> _transactions = [];
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  TransactionProvider() {
    _storageService = kIsWeb ? WebStorageService() : DatabaseService();
  }

  List<FinancialTransaction> get transactions => _transactions;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _transactions
        .where((t) => !t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get balance {
    return totalIncome - totalExpenses;
  }

  Future<void> loadTransactions() async {
    _transactions = await _storageService.getTransactions();
    notifyListeners();
  }

  Future<void> loadTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    _startDate = startDate;
    _endDate = endDate;
    _transactions = await _storageService.getTransactionsByDateRange(
      startDate,
      endDate,
    );
    notifyListeners();
  }

  Future<void> addTransaction(FinancialTransaction transaction) async {
    if (kIsWeb) {
      await (_storageService as WebStorageService).addTransaction(transaction);
    } else {
      await (_storageService as DatabaseService).insertTransaction(transaction);
    }
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _storageService.deleteTransaction(id);
    await loadTransactions();
  }

  Future<void> updateTransaction(FinancialTransaction transaction) async {
    await _storageService.updateTransaction(transaction);
    await loadTransactions();
  }
} 