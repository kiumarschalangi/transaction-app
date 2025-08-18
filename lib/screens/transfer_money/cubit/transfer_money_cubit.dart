// transfer_money_cubit.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_app/constants/strings.dart' as strings;
import 'package:transaction_app/constants/enums/http_methods.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_state.dart';

class TransferMoneyCubit extends Cubit<TransferMoneyState> {
  TransferMoneyCubit() : super(const TransferMoneyState());

  void clearLogs() {
    emit(state.copyWith(logs: <String>[strings.terminalCleared]));
  }

  void updateUrl(final String url) {
    emit(state.copyWith(url: url));
  }

  void updateHttpMethod(final HttpMethod method) {
    emit(state.copyWith(selectedMethod: method));
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

  Future<void> executeRequest() async {
    if (state.url.isEmpty) {
      _addLog('> ${strings.error}: URL cannot be empty');
      return;
    }

    Uri uri;
    try {
      uri = Uri.parse(state.url);
    } catch (e) {
      _addLog('> ${strings.error}: Invalid URL format');
      return;
    }

    _setLoading(true);
    _addLogs(<String>[
      '> EXECUTING ${state.selectedMethod.name} REQUEST...',
      '> URL: ${state.url}',
    ]);

    try {
      http.Response response;

      switch (state.selectedMethod) {
        case HttpMethod.get:
          response = await http
              .get(uri)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException('Request timed out'),
              );
          break;
        case HttpMethod.post:
          response = await http
              .post(
                uri,
                headers: <String, String>{'Content-Type': 'application/json'},
                body: jsonEncode(<dynamic, dynamic>{}), // Empty body for now
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException('Request timed out'),
              );
          break;
        case HttpMethod.put:
          response = await http
              .put(
                uri,
                headers: <String, String>{'Content-Type': 'application/json'},
                body: jsonEncode(<dynamic, dynamic>{}),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException('Request timed out'),
              );
          break;
        case HttpMethod.patch:
          response = await http
              .patch(
                uri,
                headers: <String, String>{'Content-Type': 'application/json'},
                body: jsonEncode(<dynamic, dynamic>{}),
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException('Request timed out'),
              );
          break;
        case HttpMethod.delete:
          response = await http
              .delete(uri)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException('Request timed out'),
              );
          break;
      }

      _addLogs(<String>[
        '> STATUS CODE: ${response.statusCode}',
        '> RESPONSE HEADERS:',
        const JsonEncoder.withIndent('  ').convert(response.headers),
        '> RESPONSE BODY:',
      ]);

      // Try to format JSON response
      try {
        final dynamic jsonResponse = jsonDecode(response.body);
        _addLog(const JsonEncoder.withIndent('  ').convert(jsonResponse));
      } catch (_) {
        // If not JSON, just show raw body
        _addLog(response.body);
      }

      _addLog('> REQUEST COMPLETE');
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
