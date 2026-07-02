import 'package:equatable/equatable.dart';
import 'package:transaction_app/constants/enums/http_methods.dart';

enum LogKind {
  cmd,
  info,
  header,
  body,
  status2,
  status3,
  status4,
  status5,
  err,
}

class LogEntry extends Equatable {
  const LogEntry({required this.kind, required this.text});

  final LogKind kind;
  final String text;

  @override
  List<Object> get props => <Object>[kind, text];
}

class TransferMoneyState extends Equatable {
  const TransferMoneyState({
    this.logs = const <LogEntry>[],
    this.isLoading = false,
    this.selectedMethod = HttpMethod.get,
    this.url = '',
    this.requestBody = '',
    this.isBodyVisible = false,
  });

  final List<LogEntry> logs;
  final bool isLoading;
  final HttpMethod selectedMethod;
  final String url;
  final String requestBody;
  final bool isBodyVisible;

  TransferMoneyState copyWith({
    final List<LogEntry>? logs,
    final bool? isLoading,
    final HttpMethod? selectedMethod,
    final String? url,
    final String? requestBody,
    final bool? isBodyVisible,
  }) {
    return TransferMoneyState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      url: url ?? this.url,
      requestBody: requestBody ?? this.requestBody,
      isBodyVisible: isBodyVisible ?? this.isBodyVisible,
    );
  }

  @override
  List<Object> get props => <Object>[
    logs,
    isLoading,
    selectedMethod,
    url,
    requestBody,
    isBodyVisible,
  ];
}
