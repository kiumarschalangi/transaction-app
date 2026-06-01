import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_app/components/blinking_cursor/blinking_cursor.dart';
import 'package:transaction_app/components/terminal_window_circular_button.dart';
import 'package:transaction_app/constants/colors.dart';
import 'package:transaction_app/constants/enums/http_methods.dart';
import 'package:transaction_app/constants/spaces.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_cubit.dart';
import 'package:transaction_app/cubits/theme/theme_state.dart';
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
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (final BuildContext context, final ThemeState themeState) {
        final bool isLight = themeState.isLightMode;
        return Scaffold(
          backgroundColor: AppTheme.scaffold(isLight),
          drawer: const _SettingsDrawer(),
          appBar: AppBar(
            backgroundColor: AppTheme.surface(isLight),
            title: Text(
              'RetroReq',
              style: TextStyle(
                color: AppTheme.primary(isLight),
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
      },
    );
  }
}

class _SettingsDrawer extends StatelessWidget {
  const _SettingsDrawer();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (final BuildContext context, final ThemeState state) {
        final bool isLight = state.isLightMode;
        return Drawer(
          child: Container(
            color: AppTheme.surface(isLight),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AppStrings.settingsTitle,
                          style: TextStyle(
                            color: AppTheme.primary(isLight),
                            fontFamily: AppStrings.fontFamily,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(color: AppTheme.border(isLight)),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(
                      AppStrings.lightModeLabel,
                      style: TextStyle(
                        color: AppTheme.subtext(isLight),
                        fontFamily: AppStrings.fontFamily,
                        fontSize: 14,
                      ),
                    ),
                    trailing: const _AsciiToggle(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AsciiToggle extends StatelessWidget {
  const _AsciiToggle();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (final BuildContext context, final ThemeState state) {
        final bool isLight = state.isLightMode;
        return GestureDetector(
          onTap: () => context.read<ThemeCubit>().toggleTheme(),
          child: Text(
            isLight ? AppStrings.asciiSwitchOn : AppStrings.asciiSwitchOff,
            style: TextStyle(
              color: AppTheme.primary(isLight),
              fontFamily: AppStrings.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        );
      },
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
            const Row(
              children: <Widget>[
                Expanded(child: _UrlTextField()),
                AppSpaces.h12,
                _HttpMethodDropdown(),
              ],
            ),
            const SizedBox(height: 16),
            if (state.selectedMethod == HttpMethod.post ||
                state.selectedMethod == HttpMethod.put ||
                state.selectedMethod == HttpMethod.patch)
              const Column(
                children: <Widget>[_RequestBodyButton(), AppSpaces.v16],
              ),
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
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        final bool hasBody = state.requestBody.isNotEmpty;

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _showRequestBodyDialog(context, state.requestBody),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  hasBody ? AppTheme.surface(isLight) : Colors.transparent,
              foregroundColor: AppTheme.primary(isLight),
              minimumSize: const Size(0, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(
                color:
                    hasBody
                        ? AppTheme.primary(isLight)
                        : AppTheme.border(isLight),
                width: hasBody ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  hasBody ? Icons.edit_note : Icons.add,
                  size: 18,
                  color: AppTheme.primary(isLight),
                ),
                const SizedBox(width: 8),
                Text(
                  hasBody ? 'EDIT REQUEST BODY' : 'ADD REQUEST BODY',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppStrings.fontFamily,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary(isLight),
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
    final TransferMoneyCubit cubit = context.read<TransferMoneyCubit>();
    final ThemeCubit themeCubit = context.read<ThemeCubit>();

    showDialog(
      context: context,
      builder: (final BuildContext dialogContext) {
        return BlocProvider<TransferMoneyCubit>.value(
          value: cubit,
          child: BlocProvider<ThemeCubit>.value(
            value: themeCubit,
            child: _RequestBodyDialog(initialBody: currentBody),
          ),
        );
      },
    );
  }
}

class _UrlTextField extends StatelessWidget {
  const _UrlTextField();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        return TextField(
          onChanged:
              (final String value) =>
                  context.read<TransferMoneyCubit>().updateUrl(value),
          style: TextStyle(
            color: AppTheme.primary(isLight),
            fontFamily: AppStrings.fontFamily,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Enter URL (e.g. https://api.example.com/users)',
            hintStyle: TextStyle(
              color: AppTheme.hint(isLight),
              fontFamily: AppStrings.fontFamily,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppTheme.panel(isLight),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppTheme.border(isLight)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: AppTheme.border(isLight)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                color: AppTheme.primary(isLight),
                width: 2,
              ),
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
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.panel(isLight),
            border: Border.all(color: AppTheme.border(isLight)),
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
              dropdownColor: AppTheme.panel(isLight),
              style: TextStyle(
                color: AppTheme.primary(isLight),
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
                        style: TextStyle(
                          color: AppTheme.primary(isLight),
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
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.surface(isLight),
          foregroundColor: AppTheme.primary(isLight),
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(color: AppTheme.primary(isLight), width: 2),
        ),
        child:
            isLoading
                ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppTheme.primary(isLight),
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
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (final BuildContext context, final ThemeState themeState) {
        final bool isLight = themeState.isLightMode;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.panel(isLight),
            border: Border.all(color: AppTheme.border(isLight), width: 2),
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
      },
    );
  }
}

class _TerminalHeader extends StatelessWidget {
  const _TerminalHeader();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface(isLight),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(6),
        ),
      ),
      child: Row(
        children: <Widget>[
          const WindowCircularButton(color: Colors.red),
          AppSpaces.h8,
          const WindowCircularButton(color: Colors.yellow),
          AppSpaces.h8,
          const WindowCircularButton(color: Colors.green),
          Expanded(
            child: Center(
              child: Text(
                'API Terminal',
                style: TextStyle(
                  color: AppTheme.subtext(isLight),
                  fontFamily: AppStrings.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.elevated(isLight),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.border(isLight)),
        ),
        child: Text(
          AppStrings.clearButton,
          style: TextStyle(
            color: AppTheme.subtext(isLight),
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
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (final BuildContext context, final ThemeState themeState) {
        final bool isLight = themeState.isLightMode;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            log,
            style: TextStyle(
              color:
                  log.startsWith('>')
                      ? AppTheme.primary(isLight)
                      : AppTheme.subtext(isLight),
              fontSize: 14,
              fontFamily: AppStrings.fontFamily,
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
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        if (state.logs.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 12),
          child: Row(
            children: <Widget>[
              Text(
                '> ',
                style: TextStyle(
                  color: AppTheme.primary(isLight),
                  fontSize: 14,
                  fontFamily: AppStrings.fontFamily,
                ),
              ),
              const BlinkingCursor(),
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
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border(isLight)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          AppStrings.copyright,
          style: TextStyle(
            color: AppTheme.muted(isLight),
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
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (final BuildContext context, final ThemeState themeState) {
        final bool isLight = themeState.isLightMode;
        return Dialog(
          backgroundColor: AppTheme.panel(isLight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: AppTheme.border(isLight), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.border(isLight)),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.code,
                        color: AppTheme.primary(isLight),
                        size: 20,
                      ),
                      AppSpaces.h8,
                      Text(
                        'Request Body',
                        style: TextStyle(
                          color: AppTheme.primary(isLight),
                          fontFamily: AppStrings.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          context.read<TransferMoneyCubit>().updateRequestBody(
                            '',
                          );
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.delete_outline,
                          color: AppTheme.muted(isLight),
                          size: 20,
                        ),
                        tooltip: 'Clear body',
                      ),
                    ],
                  ),
                ),
                AppSpaces.v20,
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                    maxHeight: 400,
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: TextStyle(
                      color: AppTheme.subtext(isLight),
                      fontFamily: AppStrings.fontFamily,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Enter JSON request body...\n\nExample:\n{\n  "name": "John Doe",\n  "email": "john@example.com"\n}',
                      hintStyle: TextStyle(
                        color: AppTheme.hint(isLight),
                        fontFamily: AppStrings.fontFamily,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: AppTheme.scaffold(isLight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: AppTheme.border(isLight)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(color: AppTheme.border(isLight)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                          color: AppTheme.primary(isLight),
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                AppSpaces.v24,
                Row(
                  children: <Widget>[
                    AppSpaces.h12,
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.muted(isLight),
                          minimumSize: const Size(0, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(color: AppTheme.muted(isLight)),
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
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<TransferMoneyCubit>().updateRequestBody(
                            _controller.text,
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.surface(isLight),
                          foregroundColor: AppTheme.primary(isLight),
                          minimumSize: const Size(0, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(
                            color: AppTheme.primary(isLight),
                            width: 2,
                          ),
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
      },
    );
  }
}
