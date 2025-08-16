import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlinkingCursorCubit extends Cubit<bool> {
  BlinkingCursorCubit() : super(true) {
    _startBlinking();
  }

  Timer? _timer;

  void _startBlinking() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (
      final Timer timer,
    ) {
      if (!isClosed) {
        emit(!state);
      }
    });
  }

  void stopBlinking() {
    _timer?.cancel();
  }

  void startBlinking() {
    _timer?.cancel();
    _startBlinking();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
