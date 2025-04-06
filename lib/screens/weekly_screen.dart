import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/transaction_provider.dart';
import '../models/transaction.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({super.key});

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  late DateTime _startOfWeek;
  late DateTime _endOfWeek;

  @override
  void initState() {
    super.initState();
    _initWeekDates();
    _loadTransactions();
  }

  void _initWeekDates() {
    final now = DateTime.now();
    // Encontrar o início da semana (domingo)
    _startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    // Fim da semana (sábado)
    _endOfWeek = _startOfWeek.add(const Duration(days: 6));
  }

  Future<void> _loadTransactions() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactionsByDateRange(_startOfWeek, _endOfWeek);
    });
  }

  void _previousWeek() {
    setState(() {
      _startOfWeek = _startOfWeek.subtract(const Duration(days: 7));
      _endOfWeek = _endOfWeek.subtract(const Duration(days: 7));
      _loadTransactions();
    });
  }

  void _nextWeek() {
    final now = DateTime.now();
    // Não permitir navegar para semanas futuras
    if (_startOfWeek.add(const Duration(days: 7)).isBefore(now)) {
      setState(() {
        _startOfWeek = _startOfWeek.add(const Duration(days: 7));
        _endOfWeek = _endOfWeek.add(const Duration(days: 7));
        _loadTransactions();
      });
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Column(
            children: [
              // Cabeçalho com as datas e navegação
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousWeek,
                    ),
                    Text(
                      '${DateFormat('dd/MM').format(_startOfWeek)} - ${DateFormat('dd/MM').format(_endOfWeek)}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextWeek,
                    ),
                  ],
                ),
              ),
              // Resumo financeiro
              Card(
                margin: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Resumo da Semana',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Receitas',
                                style: GoogleFonts.inter(
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                _formatCurrency(provider.totalIncome),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Despesas',
                                style: GoogleFonts.inter(
                                  color: Colors.red,
                                ),
                              ),
                              Text(
                                _formatCurrency(provider.totalExpenses),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Saldo',
                                style: GoogleFonts.inter(),
                              ),
                              Text(
                                _formatCurrency(provider.balance),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Lista de transações
              Expanded(
                child: provider.transactions.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma transação nesta semana',
                          style: GoogleFonts.inter(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = provider.transactions[index];
                          return _buildTransactionItem(context, transaction);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, FinancialTransaction transaction) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Provider.of<TransactionProvider>(context, listen: false)
                  .deleteTransaction(transaction.id!);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Excluir',
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.isIncome ? Colors.green : Colors.red,
          child: Icon(
            transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
            color: Colors.white,
          ),
        ),
        title: Text(transaction.description),
        subtitle: Text(
          '${transaction.category} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
        ),
        trailing: Text(
          _formatCurrency(transaction.amount),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: transaction.isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
} 