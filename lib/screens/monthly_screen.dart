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
  bool _isLoading = true;

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
    setState(() {
      _isLoading = true;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final start = _getStartOfMonth();
      final end = _getEndOfMonth();
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactionsByDateRange(start, end)
          .then((_) {
            setState(() {
              _isLoading = false;
            });
          });
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
    
    return Map.fromEntries(
      categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final categoryTotals = _getCategoryTotals(provider.transactions);
        
        return Scaffold(
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // Header com o mês e navegação
                    SliverAppBar(
                      backgroundColor: theme.colorScheme.primary,
                      pinned: true,
                      expandedHeight: 120,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          DateFormat('MMMM yyyy', 'pt_BR').format(_currentMonth).toUpperCase(),
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        centerTitle: false,
                        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _previousMonth,
                          tooltip: 'Mês anterior',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextMonth,
                          tooltip: 'Próximo mês',
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    
                    // Conteúdo principal
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Resumo financeiro
                            _buildSummaryCard(provider),
                            
                            const SizedBox(height: 24),
                            
                            // Gráfico de despesas por categoria
                            if (categoryTotals.isNotEmpty)
                              _buildExpensesChart(categoryTotals),
                            
                            // Mensagem quando não há dados
                            if (categoryTotals.isEmpty)
                              _buildEmptyState(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildSummaryCard(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo do Mês',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildSummaryItem(
                title: 'Receitas',
                value: provider.totalIncome,
                color: Colors.green,
                icon: Icons.arrow_upward,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                title: 'Despesas',
                value: provider.totalExpenses,
                color: Colors.red,
                icon: Icons.arrow_downward,
              ),
              const SizedBox(width: 16),
              _buildSummaryItem(
                title: 'Saldo',
                value: provider.balance,
                color: Colors.blue,
                icon: Icons.account_balance_wallet,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required double value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(value),
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesChart(Map<String, double> categoryTotals) {
    final theme = Theme.of(context);
    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Despesas por Categoria',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          AspectRatio(
            aspectRatio: 1.5,
            child: PieChart(
              PieChartData(
                sections: _getPieChartSections(categoryTotals),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                centerSpaceColor: Colors.white,
              ),
            ),
          ),
          
          const Divider(height: 32),
          
          // Legenda do gráfico
          ...categoryTotals.entries.map((entry) {
            final color = _getCategoryColor(entry.key);
            final percentage = (entry.value / total * 100).toStringAsFixed(1);
            
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    _formatCurrency(entry.value),
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 45,
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$percentage%',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.pie_chart,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma transação neste mês',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Adicione transações para visualizar o gráfico de despesas',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(Map<String, double> categoryTotals) {
    final total = categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);
    
    int i = 0;
    return categoryTotals.entries.map((entry) {
      final color = _getCategoryColor(entry.key);
      final percent = entry.value / total;
      
      i++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${(percent * 100).toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        badgeWidget: percent < 0.05 ? null : _Badge(
          entry.key.substring(0, 1),
          color,
        ),
        badgePositionPercentageOffset: 1.1,
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Alimentação':
        return Colors.blue.shade600;
      case 'Transporte':
        return Colors.red.shade600;
      case 'Moradia':
        return Colors.green.shade600;
      case 'Lazer':
        return Colors.amber.shade600;
      case 'Saúde':
        return Colors.purple.shade600;
      case 'Educação':
        return Colors.orange.shade600;
      case 'Roupas':
        return Colors.pink.shade400;
      case 'Contas':
        return Colors.teal.shade600;
      default:
        return Colors.blueGrey.shade600;
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
} 