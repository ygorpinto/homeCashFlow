import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'services/transaction_provider.dart';

// Definição de cores do tema ContaAzul
class ContaAzulTheme {
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryBlue = Color(0xFF2196F3);
  static const Color lightBlue = Color(0xFFBBDEFB);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  static const Color backgroundColor = Color(0xFFF5F7FA);
  static const Color cardColor = Colors.white;
  static const Color textPrimaryColor = Color(0xFF263238);
  static const Color textSecondaryColor = Color(0xFF607D8B);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar a formatação de data para pt_BR
  await initializeDateFormatting('pt_BR', null);
  
  // Configurar o sqflite para desktop
  if (!kIsWeb) {
    // Inicializa o sqflite_ffi para desktop
    if (isDesktop()) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'home_cash_flow.db');
    
    // Verifica se o banco de dados existe
    final exists = await databaseExists(path);
    
    if (!exists) {
      // Criar o banco de dados se não existir
      final db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE transactions(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              description TEXT NOT NULL,
              amount REAL NOT NULL,
              date TEXT NOT NULL,
              isIncome INTEGER NOT NULL,
              category TEXT NOT NULL
            )
          ''');
        },
      );
      await db.close();
    }
  }
  
  runApp(const MyApp());
}

// Verifica se está rodando em ambiente desktop
bool isDesktop() {
  return !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: 'Home Cash Flow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: ContaAzulTheme.primaryBlue,
          scaffoldBackgroundColor: ContaAzulTheme.backgroundColor,
          cardColor: ContaAzulTheme.cardColor,
          colorScheme: ColorScheme.light(
            primary: ContaAzulTheme.primaryBlue,
            secondary: ContaAzulTheme.secondaryBlue,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            error: ContaAzulTheme.errorColor,
            background: ContaAzulTheme.backgroundColor,
            surface: ContaAzulTheme.cardColor,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: ContaAzulTheme.primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: ContaAzulTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ContaAzulTheme.lightBlue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ContaAzulTheme.lightBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ContaAzulTheme.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            labelStyle: TextStyle(color: ContaAzulTheme.textSecondaryColor),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          ),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: ContaAzulTheme.lightBlue,
            labelTextStyle: MaterialStateProperty.all(
              GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            iconTheme: MaterialStateProperty.all(
              const IconThemeData(
                size: 24,
              ),
            ),
          ),
          textTheme: GoogleFonts.montserratTextTheme().copyWith(
            headlineLarge: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: ContaAzulTheme.textPrimaryColor,
            ),
            headlineMedium: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: ContaAzulTheme.textPrimaryColor,
            ),
            headlineSmall: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: ContaAzulTheme.textPrimaryColor,
            ),
            titleLarge: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: ContaAzulTheme.textPrimaryColor,
            ),
            titleMedium: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: ContaAzulTheme.textPrimaryColor,
            ),
            titleSmall: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              color: ContaAzulTheme.textPrimaryColor,
            ),
            bodyLarge: GoogleFonts.montserrat(
              color: ContaAzulTheme.textPrimaryColor,
            ),
            bodyMedium: GoogleFonts.montserrat(
              color: ContaAzulTheme.textPrimaryColor,
            ),
            bodySmall: GoogleFonts.montserrat(
              color: ContaAzulTheme.textSecondaryColor,
            ),
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          primaryColor: ContaAzulTheme.primaryBlue,
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: const Color(0xFF1E1E1E),
          colorScheme: ColorScheme.dark(
            primary: ContaAzulTheme.primaryBlue,
            secondary: ContaAzulTheme.secondaryBlue,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            error: ContaAzulTheme.errorColor,
            background: const Color(0xFF121212),
            surface: const Color(0xFF1E1E1E),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: ContaAzulTheme.darkBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: ContaAzulTheme.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              textStyle: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          ),
          textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
