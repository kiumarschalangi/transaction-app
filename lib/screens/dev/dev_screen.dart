import 'package:flutter/foundation.dart';
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

class _TestPreset {
  const _TestPreset({
    required this.label,
    required this.url,
    required this.method,
    required this.body,
    required this.description,
  });

  final String label;
  final String url;
  final HttpMethod method;
  final String body;
  final String description;
}

const List<_TestPreset> _kPresets = <_TestPreset>[
  _TestPreset(
    label: 'JSONPlaceholder',
    url: 'https://jsonplaceholder.typicode.com/posts',
    method: HttpMethod.post,
    body:
        '{\n  "title": "Test Post",\n  "body": "Hello from RetroReq",\n  "userId": 1\n}',
    description: 'POST → create a fake post (returns 201)',
  ),
  _TestPreset(
    label: 'HTTPBin',
    url: 'https://httpbin.org/post',
    method: HttpMethod.post,
    body: '{\n  "test": "echo",\n  "source": "RetroReq"\n}',
    description: 'POST → echoes your entire request back',
  ),
  _TestPreset(
    label: 'ReqRes',
    url: 'https://reqres.in/api/users',
    method: HttpMethod.post,
    body: '{\n  "name": "John Dev",\n  "job": "Tester"\n}',
    description: 'POST → create a fake user (returns 201)',
  ),
  _TestPreset(
    label: 'GET Posts',
    url: 'https://jsonplaceholder.typicode.com/posts/1',
    method: HttpMethod.get,
    body: '',
    description: 'GET → fetch a single post',
  ),
];

class DevScreen extends StatelessWidget {
  const DevScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    assert(kDebugMode, 'DevScreen must only be used in debug mode');
    return BlocProvider<TransferMoneyCubit>(
      create: (final BuildContext context) {
        final TransferMoneyCubit cubit = TransferMoneyCubit();
        cubit.updateUrl(_kPresets.first.url);
        cubit.updateHttpMethod(_kPresets.first.method);
        cubit.updateRequestBody(_kPresets.first.body);
        return cubit;
      },
      child: const _DevView(),
    );
  }
}

class _DevView extends StatelessWidget {
  const _DevView();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (final BuildContext context, final ThemeState themeState) {
        final bool isLight = themeState.isLightMode;
        return Scaffold(
          backgroundColor: AppTheme.scaffold(isLight),
          appBar: AppBar(
            backgroundColor: AppTheme.surface(isLight),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.primary(isLight)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              AppStrings.devToolsTitle,
              style: TextStyle(
                color: AppTheme.primary(isLight),
                fontFamily: AppStrings.fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _DebugBadge(),
                AppSpaces.v12,
                _PresetsSection(),
                AppSpaces.v16,
                _DevRequestConfigSection(),
                AppSpaces.v16,
                Expanded(child: _DevTerminal()),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DebugBadge extends StatelessWidget {
  const _DebugBadge();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.panel(isLight),
        border: Border.all(color: AppTheme.primary(isLight)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.bug_report_outlined,
            color: AppTheme.primary(isLight),
            size: 14,
          ),
          AppSpaces.h8,
          Text(
            AppStrings.devModeBadge,
            style: TextStyle(
              color: AppTheme.primary(isLight),
              fontFamily: AppStrings.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetsSection extends StatelessWidget {
  const _PresetsSection();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppStrings.devPresetsLabel,
          style: TextStyle(
            color: AppTheme.muted(isLight),
            fontFamily: AppStrings.fontFamily,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        AppSpaces.v8,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                _kPresets.map((final _TestPreset preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _PresetChip(preset: preset),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.preset});

  final _TestPreset preset;

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Tooltip(
      message: preset.description,
      child: OutlinedButton(
        onPressed: () {
          final TransferMoneyCubit cubit = context.read<TransferMoneyCubit>();
          cubit.updateUrl(preset.url);
          cubit.updateHttpMethod(preset.method);
          cubit.updateRequestBody(preset.body);
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.subtext(isLight),
          minimumSize: const Size(0, 34),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          side: BorderSide(color: AppTheme.border(isLight)),
        ),
        child: Text(
          preset.label,
          style: TextStyle(
            fontSize: 12,
            fontFamily: AppStrings.fontFamily,
            fontWeight: FontWeight.bold,
            color: AppTheme.subtext(isLight),
          ),
        ),
      ),
    );
  }
}

class _DevRequestConfigSection extends StatelessWidget {
  const _DevRequestConfigSection();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        return Column(
          children: <Widget>[
            const Row(
              children: <Widget>[
                Expanded(child: _DevUrlTextField()),
                AppSpaces.h12,
                _DevMethodDropdown(),
              ],
            ),
            if (state.selectedMethod == HttpMethod.post ||
                state.selectedMethod == HttpMethod.put ||
                state.selectedMethod == HttpMethod.patch) ...<Widget>[
              AppSpaces.v12,
              const _DevRequestBodyField(),
            ],
            AppSpaces.v12,
            _DevSendButton(isLoading: state.isLoading),
          ],
        );
      },
    );
  }
}

class _DevUrlTextField extends StatefulWidget {
  const _DevUrlTextField();

  @override
  State<_DevUrlTextField> createState() => _DevUrlTextFieldState();
}

class _DevUrlTextFieldState extends State<_DevUrlTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<TransferMoneyCubit>().state.url,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return BlocListener<TransferMoneyCubit, TransferMoneyState>(
      listenWhen:
          (final TransferMoneyState prev, final TransferMoneyState curr) =>
              prev.url != curr.url && curr.url != _controller.text,
      listener: (final BuildContext context, final TransferMoneyState state) {
        _controller.text = state.url;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      },
      child: TextField(
        controller: _controller,
        onChanged:
            (final String value) =>
                context.read<TransferMoneyCubit>().updateUrl(value),
        style: TextStyle(
          color: AppTheme.primary(isLight),
          fontFamily: AppStrings.fontFamily,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Enter URL',
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
            borderSide: BorderSide(color: AppTheme.primary(isLight), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _DevMethodDropdown extends StatelessWidget {
  const _DevMethodDropdown();

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

class _DevRequestBodyField extends StatefulWidget {
  const _DevRequestBodyField();

  @override
  State<_DevRequestBodyField> createState() => _DevRequestBodyFieldState();
}

class _DevRequestBodyFieldState extends State<_DevRequestBodyField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: context.read<TransferMoneyCubit>().state.requestBody,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return BlocListener<TransferMoneyCubit, TransferMoneyState>(
      listenWhen:
          (final TransferMoneyState prev, final TransferMoneyState curr) =>
              prev.requestBody != curr.requestBody &&
              curr.requestBody != _controller.text,
      listener: (final BuildContext context, final TransferMoneyState state) {
        _controller.text = state.requestBody;
      },
      child: TextField(
        controller: _controller,
        maxLines: 5,
        onChanged:
            (final String value) =>
                context.read<TransferMoneyCubit>().updateRequestBody(value),
        style: TextStyle(
          color: AppTheme.subtext(isLight),
          fontFamily: AppStrings.fontFamily,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'Request body (JSON)...',
          hintStyle: TextStyle(
            color: AppTheme.hint(isLight),
            fontFamily: AppStrings.fontFamily,
            fontSize: 13,
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
            borderSide: BorderSide(color: AppTheme.primary(isLight), width: 2),
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}

class _DevSendButton extends StatelessWidget {
  const _DevSendButton({required this.isLoading});

  final bool isLoading;

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed:
            isLoading
                ? null
                : () async {
                  try {
                    await context.read<TransferMoneyCubit>().executeRequest();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }
                },
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

class _DevTerminal extends StatelessWidget {
  const _DevTerminal();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppTheme.panel(isLight),
        border: Border.all(color: AppTheme.border(isLight), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _DevTerminalHeader(),
          Expanded(child: _DevTerminalLogs()),
          _DevTerminalPrompt(),
        ],
      ),
    );
  }
}

class _DevTerminalHeader extends StatelessWidget {
  const _DevTerminalHeader();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Container(
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
                'Response Terminal',
                style: TextStyle(
                  color: AppTheme.subtext(isLight),
                  fontFamily: AppStrings.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => context.read<TransferMoneyCubit>().clearLogs(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.elevated(isLight),
                border: Border.all(color: AppTheme.border(isLight)),
                borderRadius: BorderRadius.circular(4),
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
          ),
        ],
      ),
    );
  }
}

class _DevTerminalLogs extends StatelessWidget {
  const _DevTerminalLogs();

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: state.logs.length,
          itemBuilder: (final BuildContext context, final int index) {
            return _DevLogEntry(log: state.logs[index]);
          },
        );
      },
    );
  }
}

class _DevLogEntry extends StatelessWidget {
  const _DevLogEntry({required this.log});

  final LogEntry log;

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        log.text,
        style: TextStyle(
          color:
              log.text.startsWith('>')
                  ? AppTheme.primary(isLight)
                  : AppTheme.subtext(isLight),
          fontSize: 13,
          fontFamily: AppStrings.fontFamily,
        ),
      ),
    );
  }
}

class _DevTerminalPrompt extends StatelessWidget {
  const _DevTerminalPrompt();

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
