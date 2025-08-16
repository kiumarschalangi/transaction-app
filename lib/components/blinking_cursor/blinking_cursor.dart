import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_app/components/blinking_cursor/cubit/blinking_cursor_cubit.dart';
import 'package:transaction_app/constants/strings.dart' as strings;

class BlinkingCursor extends StatelessWidget {
  const BlinkingCursor({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocProvider<BlinkingCursorCubit>(
      create: (final BuildContext context) => BlinkingCursorCubit(),
      child: const _BlinkingCursorView(),
    );
  }
}

class _BlinkingCursorView extends StatelessWidget {
  const _BlinkingCursorView();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<BlinkingCursorCubit, bool>(
      builder: (final BuildContext context, final bool showCursor) {
        return Text(
          showCursor ? '█' : '',
          style: const TextStyle(
            color: Color(0xFF00FF00),
            fontSize: 14,
            fontFamily: strings.fontFamily,
          ),
        );
      },
    );
  }
}
