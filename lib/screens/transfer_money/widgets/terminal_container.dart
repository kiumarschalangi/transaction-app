import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transaction_app/components/blinking_cursor/blinking_cursor.dart';
import 'package:transaction_app/components/terminal_window_circular_button.dart';
import 'package:transaction_app/constants/colors.dart';
import 'package:transaction_app/constants/spaces.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_cubit.dart';
import 'package:transaction_app/cubits/theme/theme_state.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_cubit.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_state.dart';

class TerminalContainer extends StatelessWidget {
  const TerminalContainer({super.key});

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.termBg(isLight),
        border: Border.all(color: AppTheme.border(isLight)),
        borderRadius: BorderRadius.circular(13),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppTheme.glow(isLight),
            blurRadius: 50,
            spreadRadius: -24,
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _TerminalHeader(),
            Expanded(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: _TerminalLogsList()),
                  Positioned.fill(
                    child: IgnorePointer(child: _ScanlineOverlay()),
                  ),
                ],
              ),
            ),
            _TerminalPrompt(),
          ],
        ),
      ),
    );
  }
}

class _ScanlineOverlay extends StatelessWidget {
  const _ScanlineOverlay();

  @override
  Widget build(final BuildContext context) {
    return CustomPaint(painter: _ScanlinePainter());
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.09)
          ..strokeWidth = 1;
    double y = 0.5;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      y += 3;
    }
  }

  @override
  bool shouldRepaint(final _ScanlinePainter _) => false;
}

class _TerminalHeader extends StatelessWidget {
  const _TerminalHeader();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(bottom: BorderSide(color: AppTheme.border(isLight))),
      ),
      child: Row(
        children: <Widget>[
          const WindowCircularButton(color: Color(0xFFFF5F56)),
          AppSpaces.h7,
          const WindowCircularButton(color: Color(0xFFFFBD2E)),
          AppSpaces.h7,
          const WindowCircularButton(color: Color(0xFF27C93F)),
          Expanded(
            child: Center(
              child: Text(
                AppStrings.apiTerminalTitle,
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.muted(isLight),
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const _ClearButton(),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return GestureDetector(
      onTap: () => context.read<TransferMoneyCubit>().clearLogs(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.panel(isLight),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: AppTheme.border(isLight)),
        ),
        child: Text(
          AppStrings.clearButton,
          style: GoogleFonts.jetBrainsMono(
            color: AppTheme.muted(isLight),
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TerminalLogsList extends StatefulWidget {
  const _TerminalLogsList();

  @override
  State<_TerminalLogsList> createState() => _TerminalLogsListState();
}

class _TerminalLogsListState extends State<_TerminalLogsList> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return BlocListener<TransferMoneyCubit, TransferMoneyState>(
      listenWhen:
          (final TransferMoneyState prev, final TransferMoneyState curr) =>
              prev.logs.length != curr.logs.length,
      listener: (final BuildContext context, final TransferMoneyState state) {
        WidgetsBinding.instance.addPostFrameCallback(
          (final Duration _) => _scrollToBottom(),
        );
      },
      child: BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
        builder: (final BuildContext context, final TransferMoneyState state) {
          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(14),
            itemCount: state.logs.length,
            itemBuilder: (final BuildContext context, final int index) {
              return _LogEntry(log: state.logs[index]);
            },
          );
        },
      ),
    );
  }
}

class _LogEntry extends StatelessWidget {
  const _LogEntry({required this.log});

  final LogEntry log;

  Color _colorForKind(final LogKind kind, final bool isLight) {
    if (isLight) {
      return switch (kind) {
        LogKind.status3 => AppTheme.lightStatus3,
        LogKind.status4 => AppTheme.lightStatus4,
        LogKind.status5 => AppTheme.lightErr,
        LogKind.err => AppTheme.lightErr,
        LogKind.info => AppTheme.lightMuted,
        LogKind.header => AppTheme.lightMuted,
        _ => AppTheme.lightPrimary,
      };
    }
    return switch (kind) {
      LogKind.cmd => AppTheme.darkPrimary,
      LogKind.info => AppTheme.darkMuted,
      LogKind.header => AppTheme.darkMuted,
      LogKind.body => AppTheme.darkPrimary,
      LogKind.status2 => AppTheme.darkPrimary,
      LogKind.status3 => AppTheme.darkStatus3,
      LogKind.status4 => AppTheme.darkStatus4,
      LogKind.status5 => AppTheme.darkErr,
      LogKind.err => AppTheme.darkErr,
    };
  }

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (final BuildContext context, final ThemeState themeState) {
        final bool isLight = themeState.isLightMode;
        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            log.text,
            style: GoogleFonts.jetBrainsMono(
              color: _colorForKind(log.kind, isLight),
              fontSize: log.kind == LogKind.body ? 12.0 : 12.5,
              fontWeight:
                  log.kind == LogKind.cmd ? FontWeight.bold : FontWeight.normal,
              height: 1.6,
            ),
          ),
        );
      },
    );
  }
}

class _TerminalPrompt extends StatelessWidget {
  const _TerminalPrompt();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Padding(
      padding: const EdgeInsets.only(left: 14, bottom: 14, top: 4),
      child: Row(
        children: <Widget>[
          Text(
            AppStrings.terminalPrompt,
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.primary(isLight),
              fontSize: 12.5,
            ),
          ),
          const BlinkingCursor(),
        ],
      ),
    );
  }
}
