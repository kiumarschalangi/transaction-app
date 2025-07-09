import 'package:flutter/material.dart';

import 'package:transaction_app/transfer_money_screen.dart';

void main() {
  runApp(const RetroTerminalApp());
}

class RetroTerminalApp extends StatelessWidget {
  const RetroTerminalApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'Retro Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00FF00)),
        fontFamily: 'Courier',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'Courier',
          ),
          bodyLarge: TextStyle(color: Color(0xFF00FF00), fontFamily: 'Courier'),
        ),
      ),
      home: const TransferMoneyScreen(),
    );
  }
}
