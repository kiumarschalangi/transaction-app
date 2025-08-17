import 'package:equatable/equatable.dart';

class TransferMoneyState extends Equatable {
  const TransferMoneyState({
    this.logs = const <String>[],
    this.isLoading = false,
  });

  final List<String> logs;
  final bool isLoading;

  TransferMoneyState copyWith({
    final List<String>? logs,
    final bool? isLoading,
  }) {
    return TransferMoneyState(
      logs: logs ?? this.logs,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object> get props => <Object>[logs, isLoading];
}
