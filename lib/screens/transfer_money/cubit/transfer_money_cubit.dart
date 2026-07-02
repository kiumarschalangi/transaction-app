import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:transaction_app/constants/enums/http_methods.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_state.dart';

class TransferMoneyCubit extends Cubit<TransferMoneyState> {
  TransferMoneyCubit()
    : super(
        const TransferMoneyState(
          logs: <LogEntry>[
            LogEntry(
              kind: LogKind.info,
              text: '> SYSTEM ONLINE · AWAITING REQUEST',
            ),
          ],
        ),
      );

  void clearLogs() {
    emit(
      state.copyWith(
        logs: const <LogEntry>[
          LogEntry(kind: LogKind.info, text: '> TERMINAL CLEARED'),
        ],
      ),
    );
  }

  void updateUrl(final String url) {
    emit(state.copyWith(url: url));
  }

  void updateHttpMethod(final HttpMethod method) {
    emit(state.copyWith(selectedMethod: method, isBodyVisible: false));
  }

  void updateRequestBody(final String body) {
    emit(state.copyWith(requestBody: body));
  }

  void toggleBodyVisibility() {
    emit(state.copyWith(isBodyVisible: !state.isBodyVisible));
  }

  void _addLog(final LogEntry log) {
    final List<LogEntry> updatedLogs = List<LogEntry>.from(state.logs)
      ..add(log);
    emit(state.copyWith(logs: updatedLogs));
  }

  void _addLogs(final List<LogEntry> logs) {
    final List<LogEntry> updatedLogs = List<LogEntry>.from(state.logs)
      ..addAll(logs);
    emit(state.copyWith(logs: updatedLogs));
  }

  void _setLoading(final bool loading) {
    emit(state.copyWith(isLoading: loading));
  }

  Future<void> executeRequest() async {
    if (state.url.isEmpty) {
      _addLog(const LogEntry(kind: LogKind.err, text: '✕ NO URL PROVIDED'));
      return;
    }

    Uri uri;
    try {
      uri = Uri.parse(state.url);
    } catch (e) {
      _addLog(const LogEntry(kind: LogKind.err, text: '✕ INVALID URL FORMAT'));
      return;
    }

    _setLoading(true);
    _addLog(
      LogEntry(
        kind: LogKind.cmd,
        text: '> ${state.selectedMethod.name.toUpperCase()} ${state.url}',
      ),
    );

    final Stopwatch stopwatch = Stopwatch()..start();

    try {
      http.Response response;
      final Map<String, String> jsonHeaders = <String, String>{
        AppStrings.contentType: AppStrings.applicationJson,
      };
      final String body =
          state.requestBody.isNotEmpty ? state.requestBody : '{}';

      switch (state.selectedMethod) {
        case HttpMethod.get:
          response = await http
              .get(uri)
              .timeout(
                const Duration(seconds: 10),
                onTimeout:
                    () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
        case HttpMethod.post:
          response = await http
              .post(uri, headers: jsonHeaders, body: body)
              .timeout(
                const Duration(seconds: 10),
                onTimeout:
                    () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
        case HttpMethod.put:
          response = await http
              .put(uri, headers: jsonHeaders, body: body)
              .timeout(
                const Duration(seconds: 10),
                onTimeout:
                    () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
        case HttpMethod.patch:
          response = await http
              .patch(uri, headers: jsonHeaders, body: body)
              .timeout(
                const Duration(seconds: 10),
                onTimeout:
                    () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
        case HttpMethod.delete:
          response = await http
              .delete(uri)
              .timeout(
                const Duration(seconds: 10),
                onTimeout:
                    () => throw TimeoutException(AppStrings.requestTimedOut),
              );
          break;
      }

      stopwatch.stop();
      final int ms = stopwatch.elapsedMilliseconds;
      final int code = response.statusCode;
      final String reason = response.reasonPhrase ?? '';
      final String statusLine = '< $code $reason  ·  $ms ms'.trim();
      final String contentType = response.headers['content-type'] ?? '';

      final LogKind statusKind = switch (code) {
        >= 200 && < 300 => LogKind.status2,
        >= 300 && < 400 => LogKind.status3,
        >= 400 && < 500 => LogKind.status4,
        _ => LogKind.status5,
      };

      final List<LogEntry> responseLogs = <LogEntry>[
        LogEntry(kind: statusKind, text: statusLine),
        if (contentType.isNotEmpty)
          LogEntry(kind: LogKind.header, text: 'content-type: $contentType'),
      ];

      try {
        final dynamic jsonResponse = jsonDecode(response.body);
        responseLogs.add(
          LogEntry(
            kind: LogKind.body,
            text: const JsonEncoder.withIndent('  ').convert(jsonResponse),
          ),
        );
      } catch (_) {
        if (response.body.isNotEmpty) {
          responseLogs.add(LogEntry(kind: LogKind.body, text: response.body));
        } else {
          responseLogs.add(
            const LogEntry(kind: LogKind.info, text: '(empty response body)'),
          );
        }
      }

      _addLogs(responseLogs);
    } on TimeoutException catch (_) {
      _addLog(const LogEntry(kind: LogKind.err, text: '✕ REQUEST TIMED OUT'));
      throw TimeoutException(AppStrings.snackbarTimeout);
    } catch (e) {
      _addLogs(<LogEntry>[
        const LogEntry(kind: LogKind.err, text: '✕ REQUEST FAILED'),
        LogEntry(kind: LogKind.info, text: '  $e'),
      ]);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
