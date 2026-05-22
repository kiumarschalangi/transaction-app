import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/constants/colors.dart';
import 'package:transaction_app/constants/spaces.dart';
import 'package:transaction_app/constants/enums/http_methods.dart';
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
        backgroundColor: AppColors.background,
        title: const Text(
          'RetroReq',
          style: TextStyle(
            color: AppColors.primary,
            fontFamily: AppStrings.fontFamily,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            AppSpaces.v20,
            _RequestConfigSection(),
            AppSpaces.v20,
            Expanded(child: _TerminalContainer()),
            AppSpaces.v16,
            _CopyrightFooter(),
          ],
        ),
      ),
    );
  }
}

class _RequestConfigSection extends StatelessWidget {
  const _RequestConfigSection();

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
        return Column(
          children: <Widget>[
            // URL Input Row
            const Row(
              children: <Widget>[
                Expanded(child: _UrlTextField()),

                AppSpaces.h12,
                _HttpMethodDropdown(),
              ],
            ),
            const SizedBox(height: 16),
            // ← ADD THIS: Request Body Button (only for POST/PUT/PATCH)
            if (state.selectedMethod == HttpMethod.post ||
                state.selectedMethod == HttpMethod.put ||
                state.selectedMethod == HttpMethod.patch)
              const Column(
                children: <Widget>[_RequestBodyButton(), AppSpaces.v16],
              ),
            // Send Button
            _SendRequestButton(
              onPressed: () async {
                try {
                  await context.read<TransferMoneyCubit>().executeRequest();
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

class _RequestBodyButton extends StatelessWidget {
  const _RequestBodyButton();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        final bool hasBody = state.requestBody.isNotEmpty;

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showRequestBodyDialog(context, state.requestBody),
            style: OutlinedButton.styleFrom(
              backgroundColor: hasBody ? AppColors.background : Colors.transparent,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(
                color: hasBody ? AppColors.primary : AppColors.border,
                width: hasBody ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  hasBody ? Icons.edit_note : Icons.add,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  hasBody ? 'EDIT REQUEST BODY' : 'ADD REQUEST BODY',
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: AppStrings.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRequestBodyDialog(
    final BuildContext context,
    final String currentBody,
  ) {
    // Get the cubit before showing the dialog
    final TransferMoneyCubit cubit = context.read<TransferMoneyCubit>();

    showDialog(
      context: context,
      builder: (final BuildContext dialogContext) {
        // Pass the cubit to the dialog
        return BlocProvider<TransferMoneyCubit>.value(
          value: cubit,
          child: _RequestBodyDialog(initialBody: currentBody),
        );
      },
    );
  }
}

class _UrlTextField extends StatelessWidget {
  const _UrlTextField();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        return TextField(
          onChanged:
              (final String value) =>
                  context.read<TransferMoneyCubit>().updateUrl(value),
          style: const TextStyle(
            color: AppColors.primary,
            fontFamily: AppStrings.fontFamily,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Enter URL (e.g. https://api.example.com/users)',
            hintStyle: const TextStyle(
              color: Color(0xFF666666),
              fontFamily: AppStrings.fontFamily,
              fontSize: 14,
            ),
            filled: true,
            fillColor: const Color(0xFF121212),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
        );
      },
    );
  }
}

class _HttpMethodDropdown extends StatelessWidget {
  const _HttpMethodDropdown();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<HttpMethod>(
              value: state.selectedMethod,
              onChanged: (final HttpMethod? newMethod) {
                if (newMethod != null) {
                  context.read<TransferMoneyCubit>().updateHttpMethod(
                    newMethod,
                  );
                }
              },
              dropdownColor: const Color(0xFF121212),
              style: const TextStyle(
                color: AppColors.primary,
                fontFamily: AppStrings.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              items:
                  HttpMethod.values.map((final HttpMethod method) {
                    return DropdownMenuItem<HttpMethod>(
                      value: method,
                      child: Text(
                        method.name,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontFamily: AppStrings.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _SendRequestButton extends StatelessWidget {
  const _SendRequestButton({required this.onPressed, required this.isLoading});

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(final BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: const BorderSide(color: AppColors.primary, width: 2),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2,
                  ),
                )
                : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.send, size: 18),
                    AppSpaces.h8,
                    Text(
                      'SEND REQUEST',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: AppStrings.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
      ),
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
        border: Border.all(color: AppColors.border, width: 2),
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
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
      child: const Row(
        children: <Widget>[
          WindowCircularButton(color: Colors.red),
          AppSpaces.h8,
          WindowCircularButton(color: Colors.yellow),
          AppSpaces.h8,
          WindowCircularButton(color: Colors.green),
          Expanded(
            child: Center(
              child: Text(
                'API Terminal',
                style: TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontFamily: AppStrings.fontFamily,
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
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          AppStrings.clearButton,
          style: TextStyle(
            color: Color(0xFFCCCCCC),
            fontFamily: AppStrings.fontFamily,
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
          color: log.startsWith('>') ? AppColors.primary : const Color(0xFFCCCCCC),
          fontSize: 14,
          fontFamily: AppStrings.fontFamily,
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
                '> ',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontFamily: AppStrings.fontFamily,
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
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          AppStrings.copyright,
          style: TextStyle(
            color: Color(0xFF888888),
            fontSize: 12,
            fontFamily: AppStrings.fontFamily,
          ),
        ),
      ),
    );
  }
}

class _RequestBodyDialog extends StatefulWidget {
  const _RequestBodyDialog({required this.initialBody});

  final String initialBody;

  @override
  State<_RequestBodyDialog> createState() => _RequestBodyDialogState();
}

class _RequestBodyDialogState extends State<_RequestBodyDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialBody);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF121212),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Dialog Header
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.code, color: AppColors.primary, size: 20),
                  AppSpaces.h8,
                  const Text(
                    'Request Body',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontFamily: AppStrings.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Clear button in header
                  IconButton(
                    onPressed: () {
                      setState(() {
                        context.read<TransferMoneyCubit>().updateRequestBody(
                          '',
                        );
                        Navigator.of(context).pop();
                      });
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFF888888),
                      size: 20,
                    ),
                    tooltip: 'Clear body',
                  ),
                ],
              ),
            ),
            AppSpaces.v20,

            // Body Input Field
            Container(
              constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  color: Color(0xFFCCCCCC),
                  fontFamily: AppStrings.fontFamily,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText:
                      'Enter JSON request body...\n\nExample:\n{\n  "name": "John Doe",\n  "email": "john@example.com"\n}',
                  hintStyle: const TextStyle(
                    color: Color(0xFF666666),
                    fontFamily: AppStrings.fontFamily,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.black,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),

            AppSpaces.v24,

            // Action Buttons (3 buttons now)
            Row(
              children: <Widget>[
                // Clear Button
                AppSpaces.h12,
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF888888),
                      minimumSize: const Size(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Color(0xFF888888)),
                    ),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppStrings.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                AppSpaces.h12,
                // Add Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<TransferMoneyCubit>().updateRequestBody(
                        _controller.text,
                      );
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.background,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    child: const Text(
                      'ADD',
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: AppStrings.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
