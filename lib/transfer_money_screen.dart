import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:transaction_app/blinking_cursor.dart';
import 'package:transaction_app/terminal_window_circular_button.dart';

class TransferMoneyScreen extends StatefulWidget {
  const TransferMoneyScreen({super.key});

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final List<String> _logs = <String>[];
  bool _isLoading = false;

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _logs.add('> TERMINAL CLEARED');
    });
  }

  Future<void> _callKafkaService(final String type) async {
    final String url =
        type == 'deposit'
            ? 'http://10.0.2.2:8081/deposit'
            : 'http://10.0.2.2:8082/withdraw';

    final Map<String, Object> payload = <String, Object>{
      'userId': 'MOBILE_UI',
      'amount': type == 'deposit' ? 500.0 : 250.0,
    };

    setState(() {
      _isLoading = true;
      _logs.add('> SENDING $type TO KAFKA SERVICE...');
      _logs.add('> REQUEST PAYLOAD:');
      _logs.add(const JsonEncoder.withIndent('  ').convert(payload));
    });

    try {
      final http.Response response = await http
          .post(
            Uri.parse(url),
            headers: <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );

      setState(() {
        _logs.add('> RESPONSE: ${response.body}');
        _logs.add('> $type REQUEST COMPLETE');
      });
    } on TimeoutException catch (_) {
      setState(() {
        _logs.add('> ERROR: Request timed out.');
      });
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Please try again.')),
      );
    } catch (e) {
      setState(() {
        _logs.add('> ERROR: $e');
      });
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Request failed: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          'RETRO KAFKA PROJECT v1.0',
          style: TextStyle(
            color: Color(0xFF00FF00),
            fontFamily: 'Courier',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _retroButton('DEPOSIT', () => _callKafkaService('deposit')),
                const SizedBox(width: 20),
                _retroButton('WITHDRAW', () => _callKafkaService('withdraw')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  border: Border.all(color: const Color(0xFF444444), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF333333),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          const WindowCircularButton(color: Colors.red),
                          const SizedBox(width: 8),
                          const WindowCircularButton(color: Colors.yellow),
                          const SizedBox(width: 8),
                          const WindowCircularButton(color: Colors.green),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'TERMINAL',
                                style: TextStyle(
                                  color: Color(0xFFCCCCCC),
                                  fontFamily: 'Courier',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _clearLogs,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF222222),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFF444444),
                                ),
                              ),
                              child: const Text(
                                'CLEAR',
                                style: TextStyle(
                                  color: Color(0xFFCCCCCC),
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _logs.length,
                        itemBuilder: (
                          final BuildContext context,
                          final int index,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              _logs[index],
                              style: TextStyle(
                                color:
                                    _logs[index].startsWith('>')
                                        ? const Color(0xFF00FF00)
                                        : const Color(0xFFCCCCCC),
                                fontSize: 14,
                                fontFamily: 'Courier',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (_logs.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(left: 12, bottom: 12),
                        child: Row(
                          children: <Widget>[
                            Text(
                              '> ',
                              style: TextStyle(
                                color: Color(0xFF00FF00),
                                fontSize: 14,
                                fontFamily: 'Courier',
                              ),
                            ),
                            BlinkingCursor(),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF444444)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Center(
                child: Text(
                  '© 2025 BY KIUMARS CHAHARLANGI',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                    fontFamily: 'Courier',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _retroButton(final String label, final VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF333333),
        foregroundColor: const Color(0xFF00FF00),
        minimumSize: const Size(140, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: Color(0xFF00FF00)),
      ),
      child:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Color(0xFF00FF00),
                  strokeWidth: 2,
                ),
              )
              : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Courier',
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }
}
