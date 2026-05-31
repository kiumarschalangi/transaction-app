import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widget_previews.dart';
import 'package:transaction_app/components/blinking_cursor/cubit/blinking_cursor_cubit.dart';
import 'package:transaction_app/constants/colors.dart' show AppTheme;
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_cubit.dart';

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
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return BlocBuilder<BlinkingCursorCubit, bool>(
      builder: (final BuildContext context, final bool showCursor) {
        return Text(
          showCursor ? '█' : '',
          style: TextStyle(
            color: AppTheme.primary(isLight),
            fontSize: 14,
            fontFamily: AppStrings.fontFamily,
          ),
        );
      },
    );
  }
}

@Preview(name: ' cursor')
Widget defaultCursor() => const BlinkingCursor();
