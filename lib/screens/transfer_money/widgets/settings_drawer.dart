import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transaction_app/constants/colors.dart';
import 'package:transaction_app/constants/spaces.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_cubit.dart';
import 'package:transaction_app/cubits/theme/theme_state.dart';
import 'package:transaction_app/screens/dev/dev_screen.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

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
                        AppSpaces.v8,
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
