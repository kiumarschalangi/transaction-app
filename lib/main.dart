import 'package:flutter/material.dart';

import 'package:transaction_app/screens/transfer_money_screen.dart';
import 'package:transaction_app/constants/strings.dart' as strings;

void main() {
  runApp(const RetroTerminalApp());
}

class RetroTerminalApp extends StatelessWidget {
  const RetroTerminalApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: strings.appTitle,
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00FF00)),
        fontFamily: strings.fontFamily,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: strings.fontFamily,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: strings.fontFamily,
          ),
        ),
      ),
      home: const TransferMoneyScreen(),
    );
  }
}
