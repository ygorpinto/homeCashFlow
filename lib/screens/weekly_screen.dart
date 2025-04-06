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
  bool _isLoading = true;

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
    setState(() {
      _isLoading = true;
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactionsByDateRange(_startOfWeek, _endOfWeek)
          .then((_) {
            setState(() {
              _isLoading = false;
            });
          });
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
  
  String _formatDateRange() {
    final startFormat = DateFormat('dd/MM', 'pt_BR').format(_startOfWeek);
    final endFormat = DateFormat('dd/MM', 'pt_BR').format(_endOfWeek);
    return '$startFormat - $endFormat';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // Header com a semana e navegação
                    SliverAppBar(
                      backgroundColor: theme.colorScheme.primary,
                      pinned: true,
                      expandedHeight: 120,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          'SEMANA ${_formatDateRange()}',
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
                          onPressed: _previousWeek,
                          tooltip: 'Semana anterior',
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: _nextWeek,
                          tooltip: 'Próxima semana',
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    
                    // Resumo financeiro
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildSummaryCard(provider),
                      ),
                    ),
                    
                    // Cabeçalho da lista
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Transações da Semana',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${provider.transactions.length} itens',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Lista de transações
                    provider.transactions.isEmpty
                        ? SliverFillRemaining(
                            child: _buildEmptyState(),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.all(16.0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final transaction = provider.transactions[index];
                                  return _buildTransactionItem(context, transaction);
                                },
                                childCount: provider.transactions.length,
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
            'Resumo da Semana',
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
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_view_week,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma transação nesta semana',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione transações para começar a controlar seus gastos',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      BuildContext context, FinancialTransaction transaction) {
    final String formattedDate = DateFormat('E, dd/MM', 'pt_BR').format(transaction.date);
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                Provider.of<TransactionProvider>(context, listen: false)
                    .deleteTransaction(transaction.id!)
                    .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Transação excluída com sucesso!'),
                          backgroundColor: Colors.red.shade700,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    });
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Excluir',
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: transaction.isIncome 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                transaction.isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: transaction.isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              transaction.description,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transaction.category,
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: Text(
              _formatCurrency(transaction.amount),
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: transaction.isIncome ? Colors.green : Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }
} 