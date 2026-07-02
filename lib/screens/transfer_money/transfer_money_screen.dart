import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transaction_app/constants/colors.dart';
import 'package:transaction_app/constants/spaces.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_cubit.dart';
import 'package:transaction_app/cubits/theme/theme_state.dart';
import 'package:transaction_app/screens/transfer_money/cubit/transfer_money_cubit.dart';
import 'package:transaction_app/screens/transfer_money/widgets/copyright_footer.dart';
import 'package:transaction_app/screens/transfer_money/widgets/pulsing_dot.dart';
import 'package:transaction_app/screens/transfer_money/widgets/request_config_section.dart';
import 'package:transaction_app/screens/transfer_money/widgets/settings_drawer.dart';
import 'package:transaction_app/screens/transfer_money/widgets/terminal_container.dart';

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
          drawer: const SettingsDrawer(),
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
              AppStrings.appName,
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
            actions: const <Widget>[LiveIndicator()],
          ),
          body: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: <Widget>[
                AppSpaces.v10,
                RequestConfigSection(),
                AppSpaces.v12,
                Expanded(child: TerminalContainer()),
                AppSpaces.v12,
                CopyrightFooter(),
              ],
            ),
          ),
        );
      },
    );
  }
}
