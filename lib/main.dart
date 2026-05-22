import 'package:flutter/material.dart';

import 'package:transaction_app/screens/transfer_money/transfer_money_screen.dart';
import 'package:transaction_app/constants/strings.dart';

void main() {
  runApp(const RetroTerminalApp());
}

class RetroTerminalApp extends StatelessWidget {
  const RetroTerminalApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00FF00)),
        fontFamily: AppStrings.fontFamily,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: AppStrings.fontFamily,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: AppStrings.fontFamily,
          ),
        ),
      ),
      home: const TransferMoneyScreen(),
    );
  }
}
