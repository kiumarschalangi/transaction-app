import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widget_previews.dart';
import 'package:transaction_app/components/blinking_cursor/cubit/blinking_cursor_cubit.dart';
import 'package:transaction_app/constants/colors.dart' show AppTheme;
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
        return AnimatedOpacity(
          opacity: showCursor ? 1.0 : 0.0,
          duration: Duration.zero,
          child: Container(
            width: 8,
            height: 15,
            decoration: BoxDecoration(
              color: AppTheme.primary(isLight),
              boxShadow: <BoxShadow>[
                BoxShadow(color: AppTheme.glow(isLight), blurRadius: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

@Preview(name: ' cursor')
Widget defaultCursor() => const BlinkingCursor();
