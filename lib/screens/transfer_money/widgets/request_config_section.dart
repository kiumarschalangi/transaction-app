import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transaction_app/constants/colors.dart';
import 'package:transaction_app/constants/enums/http_methods.dart';
import 'package:transaction_app/constants/spaces.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_cubit.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_cubit.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_state.dart';

class RequestConfigSection extends StatelessWidget {
  const RequestConfigSection({super.key});

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
                AppSpaces.h10,
                _HttpMethodDropdown(),
              ],
            ),
            AppSpaces.v12,
            if (state.selectedMethod == HttpMethod.post ||
                state.selectedMethod == HttpMethod.put ||
                state.selectedMethod == HttpMethod.patch) ...<Widget>[
              const _RequestBodyToggleButton(),
              AppSpaces.v12,
              if (state.isBodyVisible) ...<Widget>[
                const _InlineRequestBodyEditor(),
                AppSpaces.v12,
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
                    state.isBodyVisible
                        ? AppStrings.bodyCollapseIcon
                        : AppStrings.bodyExpandIcon,
                    style: GoogleFonts.jetBrainsMono(
                      color: AppTheme.primary(isLight),
                      fontSize: 16,
                      height: 1,
                    ),
                  ),
                  AppSpaces.h9,
                  Text(
                    state.isBodyVisible
                        ? AppStrings.hideRequestBody
                        : AppStrings.addRequestBody,
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
          AppStrings.requestBodyLabel,
          style: GoogleFonts.jetBrainsMono(
            color: AppTheme.muted(isLight),
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
        AppSpaces.v6,
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
              hintText: AppStrings.requestBodyHint,
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
            hintText: AppStrings.urlHint,
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
                AppStrings.dropdownArrow,
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
                      AppSpaces.h9,
                      Text(
                        AppStrings.transmitting,
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
                        AppStrings.sendIcon,
                        style: GoogleFonts.jetBrainsMono(
                          color: AppTheme.primary(isLight),
                          fontSize: 15,
                        ),
                      ),
                      AppSpaces.h10,
                      Text(
                        AppStrings.sendRequest,
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
