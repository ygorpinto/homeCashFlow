import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/transaction_provider.dart';
import '../models/transaction.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late DateTime _currentMonth;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(_selectedYear, _selectedMonth, 1);
    _loadTransactions();
  }

  DateTime _getStartOfMonth() {
    return DateTime(_selectedYear, _selectedMonth, 1);
  }

  DateTime _getEndOfMonth() {
    return DateTime(_selectedYear, _selectedMonth + 1, 0);
  }

  Future<void> _loadTransactions() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final start = _getStartOfMonth();
      final end = _getEndOfMonth();
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactionsByDateRange(start, end);
    });
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
      _currentMonth = DateTime(_selectedYear, _selectedMonth, 1);
      _loadTransactions();
    });
  }

  void _nextMonth() {
    final now = DateTime.now();
    // Não permitir navegar para meses futuros
    if (_selectedYear < now.year ||
        (_selectedYear == now.year && _selectedMonth < now.month)) {
      setState(() {
        if (_selectedMonth == 12) {
          _selectedMonth = 1;
          _selectedYear++;
        } else {
          _selectedMonth++;
        }
        _currentMonth = DateTime(_selectedYear, _selectedMonth, 1);
        _loadTransactions();
      });
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  Map<String, double> _getCategoryTotals(List<FinancialTransaction> transactions) {
    final Map<String, double> categoryTotals = {};
    
    for (final transaction in transactions) {
      if (!transaction.isIncome) {
        final category = transaction.category;
        categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction.amount;
      }
    }
    
    return categoryTotals;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final categoryTotals = _getCategoryTotals(provider.transactions);
        
        return Scaffold(
          body: Column(
            children: [
              // Cabeçalho com o mês e navegação
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      DateFormat('MMMM yyyy', 'pt_BR').format(_currentMonth),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _nextMonth,
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
                        'Resumo do Mês',
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
              // Gráfico de despesas por categoria
              if (categoryTotals.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Despesas por Categoria',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: _getPieChartSections(categoryTotals),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Legenda do gráfico
                      Column(
                        children: categoryTotals.entries.map((entry) {
                          final color = _getCategoryColor(entry.key);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: color,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(entry.key),
                                ),
                                Text(
                                  _formatCurrency(entry.value),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              // Mensagem quando não há dados
              if (categoryTotals.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Nenhuma transação neste mês',
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _getPieChartSections(Map<String, double> categoryTotals) {
    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    
    int i = 0;
    return categoryTotals.entries.map((entry) {
      final color = colors[i % colors.length];
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${(entry.value / total * 100).toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Alimentação':
        return Colors.blue;
      case 'Transporte':
        return Colors.red;
      case 'Moradia':
        return Colors.green;
      case 'Lazer':
        return Colors.yellow;
      case 'Saúde':
        return Colors.purple;
      case 'Educação':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
} 