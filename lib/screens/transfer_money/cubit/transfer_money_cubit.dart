import 'package:http/http.dart' as http;
import 'package:transaction_app/constants/strings.dart' as strings;
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_state.dart';

class TransferMoneyCubit extends Cubit<TransferMoneyState> {
  TransferMoneyCubit() : super(const TransferMoneyState());

  void clearLogs() {
    emit(state.copyWith(logs: <String>[strings.terminalCleared]));
  }

  void _addLog(final String log) {
    final List<String> updatedLogs = List<String>.from(state.logs)..add(log);
    emit(state.copyWith(logs: updatedLogs));
  }

  void _addLogs(final List<String> logs) {
    final List<String> updatedLogs = List<String>.from(state.logs)
      ..addAll(logs);
    emit(state.copyWith(logs: updatedLogs));
  }

  void _setLoading(final bool loading) {
    emit(state.copyWith(isLoading: loading));
  }

  Future<void> callKafkaService(final String type) async {
    final String url =
        type == strings.deposit
            ? 'http://10.0.2.2:8082/deposit'
            : 'http://10.0.2.2:8083/withdraw';

    final Map<String, Object> payload = <String, Object>{
      'accountId': 'MOBILE_UI',
      'amount': type == strings.deposit ? 50 : 25,
    };

    _setLoading(true);
    _addLogs(<String>[
      '> SENDING $type TO KAFKA SERVICE...',
      '> REQUEST PAYLOAD:',
      const JsonEncoder.withIndent('  ').convert(payload),
    ]);

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

      _addLogs(<String>[
        '> RESPONSE: ${response.body}',
        '> $type REQUEST COMPLETE',
      ]);
    } on TimeoutException catch (_) {
      _addLog('> ${strings.error}: Request timed out.');
      throw TimeoutException('Request timed out. Please try again.');
    } catch (e) {
      _addLog('> ${strings.error}: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getBalance() async {
    const String url = 'http://10.0.2.2:8084/balance';

    _setLoading(true);
    _addLog('> FETCHING BALANCE...');

    try {
      final http.Response response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );

      final dynamic jsonResponse = jsonDecode(response.body);
      _addLogs(<String>[
        '> RESPONSE:',
        const JsonEncoder.withIndent('  ').convert(jsonResponse),
      ]);
    } on TimeoutException catch (_) {
      _addLog('> ${strings.error}: Request timed out.');
      throw TimeoutException('Request timed out. Please try again.');
    } catch (e) {
      _addLog('> ${strings.error}: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
