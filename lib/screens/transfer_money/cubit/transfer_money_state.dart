// transfer_money_state.dart
import 'package:equatable/equatable.dart';
import 'package:transaction_app/constants/enums/http_methods.dart';

class TransferMoneyState extends Equatable {
  const TransferMoneyState({
    this.logs = const <String>[],
    this.isLoading = false,
    this.selectedMethod = HttpMethod.get,
    this.url = '',
  });

  final List<String> logs;
  final bool isLoading;
  final HttpMethod selectedMethod;
  final String url;

  TransferMoneyState copyWith({
    final List<String>? logs,
    final bool? isLoading,
    final HttpMethod? selectedMethod,
    final String? url,
  }) {
    return TransferMoneyState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      url: url ?? this.url,
    );
  }

  @override
  List<Object> get props => <Object>[logs, isLoading, selectedMethod, url];
}
