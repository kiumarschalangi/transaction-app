import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transaction_app/components/blinking_cursor/blinking_cursor.dart';
import 'package:transaction_app/components/terminal_window_circular_button.dart';
import 'package:transaction_app/constants/colors.dart';
import 'package:transaction_app/constants/enums/http_methods.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_cubit.dart';
import 'package:transaction_app/cubits/theme/theme_state.dart';
import 'package:transaction_app/screens/dev/dev_screen.dart';
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
            backgroundColor: AppTheme.scaffold(isLight),
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: AppTheme.primary(isLight)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppTheme.border(isLight), height: 1),
            ),
            title: Text(
              'RetroReq',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.primary(isLight),
                fontWeight: FontWeight.w800,
                fontSize: 21,
                letterSpacing: 2.5,
                shadows: <Shadow>[
                  Shadow(color: AppTheme.glow(isLight), blurRadius: 16),
                ],
              ),
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: <Widget>[
                    Text(
                      'LIVE',
                      style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.muted(isLight),
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const _PulsingDot(),
                  ],
                ),
              ),
            ],
          ),
          body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: <Widget>[
                SizedBox(height: 10),
                _RequestConfigSection(),
                SizedBox(height: 12),
                Expanded(child: _TerminalContainer()),
                SizedBox(height: 12),
                _CopyrightFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return AnimatedBuilder(
      animation: _controller,
      builder: (final BuildContext context, final Widget? child) {
        return Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primary(isLight),
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(color: AppTheme.glow(isLight), blurRadius: 9),
                ],
              ),
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
            color: AppTheme.panel(isLight),
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
                          style: GoogleFonts.jetBrainsMono(
                            color: AppTheme.primary(isLight),
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
                      style: GoogleFonts.jetBrainsMono(
                        color: AppTheme.subtext(isLight),
                        fontSize: 14,
                      ),
                    ),
                    trailing: const _AsciiToggle(),
                  ),
                  if (kDebugMode) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Divider(color: AppTheme.border(isLight)),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.bug_report_outlined,
                        color: AppTheme.primary(isLight),
                        size: 18,
                      ),
                      title: Text(
                        AppStrings.devToolsLabel,
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.subtext(isLight),
                          fontSize: 14,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppTheme.muted(isLight),
                        size: 18,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder:
                                (final BuildContext context) =>
                                    const DevScreen(),
                          ),
                        );
                      },
                    ),
                  ],
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
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.primary(isLight),
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
                SizedBox(width: 10),
                _HttpMethodDropdown(),
              ],
            ),
            const SizedBox(height: 12),
            if (state.selectedMethod == HttpMethod.post ||
                state.selectedMethod == HttpMethod.put ||
                state.selectedMethod == HttpMethod.patch) ...<Widget>[
              const _RequestBodyToggleButton(),
              const SizedBox(height: 12),
              if (state.isBodyVisible) ...<Widget>[
                const _InlineRequestBodyEditor(),
                const SizedBox(height: 12),
              ],
            ],
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

class _RequestBodyToggleButton extends StatelessWidget {
  const _RequestBodyToggleButton();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return BlocBuilder<TransferMoneyCubit, TransferMoneyState>(
      builder: (final BuildContext context, final TransferMoneyState state) {
        return GestureDetector(
          onTap:
              () => context.read<TransferMoneyCubit>().toggleBodyVisibility(),
          child: CustomPaint(
            painter: _DashedRoundedBorderPainter(
              color: AppTheme.border(isLight),
              radius: 11,
            ),
            child: SizedBox(
              height: 46,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    state.isBodyVisible ? '−' : '+',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.primary(isLight),
                      fontSize: 16,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    state.isBodyVisible
                        ? 'HIDE REQUEST BODY'
                        : 'ADD REQUEST BODY',
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.primary(isLight),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
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

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint =
        Paint()
          ..color = color
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(radius),
    );
    final Path path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = (distance + 6.0).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 10.0;
      }
    }
  }

  @override
  bool shouldRepaint(final _DashedRoundedBorderPainter old) =>
      old.color != color || old.radius != radius;
}

class _InlineRequestBodyEditor extends StatefulWidget {
  const _InlineRequestBodyEditor();

  @override
  State<_InlineRequestBodyEditor> createState() =>
      _InlineRequestBodyEditorState();
}

class _InlineRequestBodyEditorState extends State<_InlineRequestBodyEditor> {
  late final TextEditingController _controller;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'REQUEST BODY · JSON',
          style: GoogleFonts.jetBrainsMono(
            color: AppTheme.muted(isLight),
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 118,
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            onChanged:
                (final String value) =>
                    context.read<TransferMoneyCubit>().updateRequestBody(value),
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.primary(isLight),
              fontSize: 12.5,
              height: 1.55,
            ),
            cursorColor: AppTheme.primary(isLight),
            decoration: InputDecoration(
              hintText: '{\n  "key": "value"\n}',
              hintStyle: GoogleFonts.jetBrainsMono(
                color: AppTheme.hint(isLight),
                fontSize: 12.5,
              ),
              filled: true,
              fillColor: AppTheme.termBg(isLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: AppTheme.border(isLight)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: AppTheme.border(isLight)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(
                  color: AppTheme.primary(isLight),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ),
      ],
    );
  }
}

class _UrlTextField extends StatefulWidget {
  const _UrlTextField();

  @override
  State<_UrlTextField> createState() => _UrlTextFieldState();
}

class _UrlTextFieldState extends State<_UrlTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    final bool isFocused = _focusNode.hasFocus;
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Container(
        height: 50,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppTheme.panel(isLight),
          border: Border.all(
            color:
                isFocused
                    ? AppTheme.primary(isLight)
                    : AppTheme.border(isLight),
            width: isFocused ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(11),
        ),
        child: TextField(
          focusNode: _focusNode,
          onChanged:
              (final String value) =>
                  context.read<TransferMoneyCubit>().updateUrl(value),
          style: GoogleFonts.jetBrainsMono(
            color: AppTheme.primary(isLight),
            fontSize: 13,
          ),
          cursorColor: AppTheme.primary(isLight),
          decoration: InputDecoration(
            hintText: 'Enter URL  (e.g. https://…)',
            hintStyle: GoogleFonts.jetBrainsMono(
              color: AppTheme.hint(isLight),
              fontSize: 13,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            isDense: true,
          ),
        ),
      ),
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
          height: 50,
          width: 104,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppTheme.panel(isLight),
            border: Border.all(color: AppTheme.border(isLight)),
            borderRadius: BorderRadius.circular(11),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<HttpMethod>(
              value: state.selectedMethod,
              isExpanded: true,
              onChanged: (final HttpMethod? newMethod) {
                if (newMethod != null) {
                  context.read<TransferMoneyCubit>().updateHttpMethod(
                    newMethod,
                  );
                }
              },
              dropdownColor: AppTheme.panel(isLight),
              icon: Text(
                '▼',
                style: GoogleFonts.jetBrainsMono(
                  color: AppTheme.primary(isLight),
                  fontSize: 9,
                ),
              ),
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.primary(isLight),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
              items:
                  HttpMethod.values.map((final HttpMethod method) {
                    return DropdownMenuItem<HttpMethod>(
                      value: method,
                      child: Text(
                        method.name.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.primary(isLight),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
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
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.accentSoft(isLight),
          border: Border.all(color: AppTheme.primary(isLight), width: 1.5),

          borderRadius: BorderRadius.circular(11),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppTheme.glow(isLight).withAlpha(2),
              blurRadius: 10,
              spreadRadius: -4,
            ),
            BoxShadow(
              color: AppTheme.glow(isLight).withAlpha(20),
              blurRadius: 2,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Center(
          child:
              isLoading
                  ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          color: AppTheme.primary(isLight),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        'TRANSMITTING…',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.primary(isLight),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '▶',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.primary(isLight),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'SEND REQUEST',
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.primary(isLight),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class _TerminalContainer extends StatelessWidget {
  const _TerminalContainer();

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
          const SizedBox(width: 7),
          const WindowCircularButton(color: Color(0xFFFFBD2E)),
          const SizedBox(width: 7),
          const WindowCircularButton(color: Color(0xFF27C93F)),
          Expanded(
            child: Center(
              child: Text(
                'API Terminal',
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
            '> ',
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

class _CopyrightFooter extends StatelessWidget {
  const _CopyrightFooter();

  @override
  Widget build(final BuildContext context) {
    final bool isLight = context.watch<ThemeCubit>().state.isLightMode;
    return Center(
      child: Text(
        AppStrings.copyright,
        style: GoogleFonts.jetBrainsMono(
          color: AppTheme.muted(isLight),
          fontSize: 9,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
