import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../services/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  final bool initialIsIncome;

  const AddTransactionScreen({
    super.key, 
    this.initialIsIncome = false,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  late bool _isIncome;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  final List<String> _incomeCategories = [
    'Salário',
    'Investimentos',
    'Freelance',
    'Presente',
    'Reembolso',
    'Outros',
  ];

  final List<String> _expenseCategories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Lazer',
    'Saúde',
    'Educação',
    'Roupas',
    'Contas',
    'Outros',
  ];

  @override
  void initState() {
    super.initState();
    _isIncome = widget.initialIsIncome;
    _categoryController.text = _isIncome ? _incomeCategories.first : _expenseCategories.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<String> get _currentCategories => _isIncome ? _incomeCategories : _expenseCategories;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final transaction = FinancialTransaction(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        isIncome: _isIncome,
        category: _categoryController.text,
      );

      Provider.of<TransactionProvider>(context, listen: false)
          .addTransaction(transaction)
          .then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isIncome 
                      ? 'Receita adicionada com sucesso!' 
                      : 'Despesa adicionada com sucesso!'
                ),
                backgroundColor: _isIncome 
                    ? Colors.green.shade700 
                    : Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
            Navigator.pop(context);
          })
          .catchError((error) {
            setState(() {
              _isSubmitting = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao adicionar transação: $error'),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isIncome ? 'Nova Receita' : 'Nova Despesa',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _isIncome ? Colors.green.shade600 : Colors.red.shade600,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Tipo de Transação
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
                  const SizedBox(height: 8),
                  Text(
                    'Tipo de Transação',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTransactionTypeButton(
                          label: 'Receita',
                          isSelected: _isIncome,
                          color: Colors.green,
                          onTap: () => setState(() {
                            if (!_isIncome) {
                              _isIncome = true;
                              _categoryController.text = _incomeCategories.first;
                            }
                          }),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTransactionTypeButton(
                          label: 'Despesa',
                          isSelected: !_isIncome,
                          color: Colors.red,
                          onTap: () => setState(() {
                            if (_isIncome) {
                              _isIncome = false;
                              _categoryController.text = _expenseCategories.first;
                            }
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Detalhes da Transação
            Container(
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
                    'Detalhes da Transação',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Descrição
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.description_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma descrição';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Valor
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira um valor';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor, insira um valor válido';
                      }
                      if (double.parse(value) <= 0) {
                        return 'O valor deve ser maior que zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Categoria
                  DropdownButtonFormField<String>(
                    value: _categoryController.text.isEmpty
                        ? _currentCategories.first
                        : _categoryController.text,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: _currentCategories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _categoryController.text = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, selecione uma categoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Data
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Data',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        controller: TextEditingController(
                          text: '${_selectedDate.day.toString().padLeft(2, '0')}/'
                              '${_selectedDate.month.toString().padLeft(2, '0')}/'
                              '${_selectedDate.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botão Salvar
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isIncome ? Colors.green.shade600 : Colors.red.shade600,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _isIncome 
                      ? Colors.green.withOpacity(0.5) 
                      : Colors.red.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Salvar',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeButton({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? color : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 