// transfer_money_cubit.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_app/constants/enums/http_methods.dart';

import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_state.dart';

class TransferMoneyCubit extends Cubit<TransferMoneyState> {
  TransferMoneyCubit() : super(const TransferMoneyState());

  void clearLogs() {
    emit(state.copyWith(logs: <String>[AppStrings.terminalCleared]));
  }

  void updateUrl(final String url) {
    emit(state.copyWith(url: url));
  }

  void updateHttpMethod(final HttpMethod method) {
    emit(state.copyWith(selectedMethod: method));
  }

  // ← ADD THIS METHOD
  void updateRequestBody(final String body) {
    emit(state.copyWith(requestBody: body));
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
      _addLog('> ${AppStrings.error}: URL cannot be empty');
      return;
    }

    Uri uri;
    try {
      uri = Uri.parse(state.url);
    } catch (e) {
      _addLog('> ${AppStrings.error}: Invalid URL format');
      return;
    }

    _setLoading(true);
    _addLogs(<String>[
      '> EXECUTING ${state.selectedMethod.name} REQUEST...',
      '> URL: ${state.url}',
    ]);

    // ← ADD THIS: Log request body if present
    if (state.requestBody.isNotEmpty &&
        (state.selectedMethod == HttpMethod.post ||
            state.selectedMethod == HttpMethod.put ||
            state.selectedMethod == HttpMethod.patch)) {
      _addLogs(<String>['> REQUEST BODY:', state.requestBody]);
    }

    try {
      http.Response response;

      switch (state.selectedMethod) {
        case HttpMethod.get:
          response = await http
              .get(uri)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
        case HttpMethod.post:
          // ← MODIFY THIS: Use actual request body
          response = await http
              .post(
                uri,
                headers: <String, String>{AppStrings.contentType: AppStrings.applicationJson},
                body: state.requestBody.isNotEmpty ? state.requestBody : '{}',
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
        case HttpMethod.put:
          // ← MODIFY THIS: Use actual request body
          response = await http
              .put(
                uri,
                headers: <String, String>{AppStrings.contentType: AppStrings.applicationJson},
                body: state.requestBody.isNotEmpty ? state.requestBody : '{}',
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
        case HttpMethod.patch:
          // ← MODIFY THIS: Use actual request body
          response = await http
              .patch(
                uri,
                headers: <String, String>{AppStrings.contentType: AppStrings.applicationJson},
                body: state.requestBody.isNotEmpty ? state.requestBody : '{}',
              )
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
        case HttpMethod.delete:
          response = await http
              .delete(uri)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
      }

      _addLogs(<String>[
        '> STATUS CODE: ${response.statusCode}',
        '> RESPONSE HEADERS:',
        const JsonEncoder.withIndent('  ').convert(response.headers),
        '> RESPONSE BODY:',
      ]);

      try {
        final dynamic jsonResponse = jsonDecode(response.body);
        _addLog(const JsonEncoder.withIndent('  ').convert(jsonResponse));
      } catch (_) {
        _addLog(response.body);
      }

      _addLog('> REQUEST COMPLETE');
    } on TimeoutException catch (_) {
      _addLog(AppStrings.requestTimeoutError);
      throw TimeoutException(AppStrings.snackbarTimeout);
    } catch (e) {
      _addLog('> ${AppStrings.error}: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
