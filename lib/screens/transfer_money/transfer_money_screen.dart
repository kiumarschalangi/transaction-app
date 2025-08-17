// transfer_money_screen.dart

import 'package:transaction_app/constants/strings.dart' as strings;
import 'package:transaction_app/constants/colors.dart' as colors;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_app/components/blinking_cursor/blinking_cursor.dart';
import 'package:transaction_app/components/terminal_window_circular_button.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_cubit.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_state.dart';

class TransferMoneyScreen extends StatelessWidget {
  const TransferMoneyScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocProvider<TransferMoneyCubit>(
      create: (final BuildContext context) => TransferMoneyCubit(),
      child: const _TransferMoneyView(),
    );
  }
}

class _TransferMoneyView extends StatelessWidget {
  const _TransferMoneyView();

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: colors.background,
        title: const Text(
          strings.appBarTitle,
          style: TextStyle(
            color: colors.primary,
            fontFamily: strings.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            _ActionButtonsRow(),
            SizedBox(height: 20),
            Expanded(child: _TerminalContainer()),
            SizedBox(height: 16),
            _CopyrightFooter(),
          ],
        ),
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  void _handleError(final BuildContext context, final Object error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.toString())));
  }

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _RetroButton(
              label: strings.deposit,
              onPressed: () async {
                try {
                  await context.read<TransferMoneyCubit>().callKafkaService(
                    strings.deposit,
                  );
                } catch (e) {
                  if (context.mounted) {
                    _handleError(context, e);
                  }
                }
              },
              isLoading: state.isLoading,
            ),
            const SizedBox(width: 14),
            _RetroButton(
              label: strings.withdraw,
              onPressed: () async {
                try {
                  await context.read<TransferMoneyCubit>().callKafkaService(
                    strings.withdraw,
                  );
                } catch (e) {
                  if (context.mounted) {
                    _handleError(context, e);
                  }
                }
              },
              isLoading: state.isLoading,
            ),
            const SizedBox(width: 14),
            _RetroButton(
              label: 'Balance',
              onPressed: () async {
                try {
                  await context.read<TransferMoneyCubit>().getBalance();
                } catch (e) {
                  if (context.mounted) {
                    _handleError(context, e);
                  }
                }
              },
              isLoading: state.isLoading,
            ),
          ],
        );
      },
    );
  }
}

class _TerminalContainer extends StatelessWidget {
  const _TerminalContainer();

  @override
  Widget build(final BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        border: Border.all(color: colors.border, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _TerminalHeader(),
          Expanded(child: _TerminalLogsList()),
          _TerminalPrompt(),
        ],
      ),
    );
  }
}

class _TerminalHeader extends StatelessWidget {
  const _TerminalHeader();

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
      child: const Row(
        children: <Widget>[
          WindowCircularButton(color: Colors.red),
          SizedBox(width: 8),
          WindowCircularButton(color: Colors.yellow),
          SizedBox(width: 8),
          WindowCircularButton(color: Colors.green),
          Expanded(
            child: Center(
              child: Text(
                strings.terminalTitle,
                style: TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontFamily: strings.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _ClearButton(),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton();

  @override
  Widget build(final BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<TransferMoneyCubit>().clearLogs(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: colors.border),
        ),
        child: const Text(
          strings.clearButton,
          style: TextStyle(
            color: Color(0xFFCCCCCC),
            fontFamily: strings.fontFamily,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _TerminalLogsList extends StatelessWidget {
  const _TerminalLogsList();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.logs.length,
          itemBuilder: (final BuildContext context, final int index) {
            return _LogEntry(log: state.logs[index]);
          },
        );
      },
    );
  }
}

class _LogEntry extends StatelessWidget {
  const _LogEntry({required this.log});

  final String log;

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        log,
        style: TextStyle(
          color: log.startsWith('>') ? colors.primary : const Color(0xFFCCCCCC),
          fontSize: 14,
          fontFamily: strings.fontFamily,
        ),
      ),
    );
  }
}

class _TerminalPrompt extends StatelessWidget {
  const _TerminalPrompt();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        if (state.logs.isEmpty) return const SizedBox.shrink();

        return const Padding(
          padding: EdgeInsets.only(left: 12, bottom: 12),
          child: Row(
            children: <Widget>[
              Text(
                strings.terminalPrompt,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 14,
                  fontFamily: strings.fontFamily,
                ),
              ),
              BlinkingCursor(),
            ],
          ),
        );
      },
    );
  }
}

class _CopyrightFooter extends StatelessWidget {
  const _CopyrightFooter();

  @override
  Widget build(final BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          strings.copyright,
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 12,
            fontFamily: strings.fontFamily,
          ),
        ),
      ),
    );
  }
}

@override
Widget build(final BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: const Color(0xFF222222),
      title: const Text(
        strings.appBarTitle,
        style: TextStyle(
          color: colors.primary,
          fontFamily: strings.fontFamily,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    body: const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: <Widget>[
          SizedBox(height: 20),
          _ActionButtonsRow(),
          SizedBox(height: 20),
          Expanded(child: _TerminalContainer()),
          SizedBox(height: 16),
          _CopyrightFooter(),
        ],
      ),
    ),
  );
}

class _RetroButton extends StatelessWidget {
  const _RetroButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(final BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.background,
        foregroundColor: colors.primary,
        minimumSize: const Size(120, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: colors.primary),
      ),
      child:
          isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: colors.primary,
                  strokeWidth: 2,
                ),
              )
              : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: strings.fontFamily,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }
}
