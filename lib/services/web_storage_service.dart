import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class WebStorageService {
  static const String _transactionsKey = 'transactions';

  Future<List<FinancialTransaction>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = prefs.getStringList(_transactionsKey) ?? [];
    return transactionsJson
        .map((json) => FinancialTransaction.fromMap(jsonDecode(json)))
        .toList();
  }

  Future<void> saveTransactions(List<FinancialTransaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final transactionsJson = transactions
        .map((transaction) => jsonEncode(transaction.toMap()))
        .toList();
    await prefs.setStringList(_transactionsKey, transactionsJson);
  }

  Future<int> addTransaction(FinancialTransaction transaction) async {
    final transactions = await getTransactions();
    
    // Gerar um ID para a transação
    final newTransaction = FinancialTransaction(
      id: transactions.isEmpty ? 1 : (transactions.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1),
      description: transaction.description,
      amount: transaction.amount,
      date: transaction.date,
      isIncome: transaction.isIncome,
      category: transaction.category,
    );
    
    transactions.add(newTransaction);
    await saveTransactions(transactions);
    return newTransaction.id!;
  }

  Future<void> deleteTransaction(int id) async {
    final transactions = await getTransactions();
    transactions.removeWhere((transaction) => transaction.id == id);
    await saveTransactions(transactions);
  }

  Future<void> updateTransaction(FinancialTransaction transaction) async {
    final transactions = await getTransactions();
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      transactions[index] = transaction;
      await saveTransactions(transactions);
    }
  }

  Future<List<FinancialTransaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final transactions = await getTransactions();
    return transactions
        .where((transaction) =>
            transaction.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            transaction.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }
} 