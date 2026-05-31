import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_app/constants/colors.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_cubit.dart';
import 'package:transaction_app/cubits/theme/theme_state.dart';
import 'package:transaction_app/screens/transfer_money/transfer_money_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ThemeCubit themeCubit = ThemeCubit();
  await themeCubit.loadTheme();
  runApp(
    BlocProvider<ThemeCubit>.value(
      value: themeCubit,
      child: const RetroTerminalApp(),
    ),
  );
}

class RetroTerminalApp extends StatelessWidget {
  const RetroTerminalApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (final BuildContext context, final ThemeState state) {
        final bool isLight = state.isLightMode;
        return MaterialApp(
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme:
              isLight
                  ? ThemeData(
                    useMaterial3: true,
                    colorScheme: const ColorScheme.light(
                      primary: AppTheme.lightPrimary,
                    ),
                    scaffoldBackgroundColor: AppTheme.lightScaffold,
                    fontFamily: AppStrings.fontFamily,
                    snackBarTheme: const SnackBarThemeData(
                      backgroundColor: AppTheme.lightSurface,
                      contentTextStyle: TextStyle(
                        color: AppTheme.lightSubtext,
                        fontFamily: AppStrings.fontFamily,
                      ),
                    ),
                  )
                  : ThemeData(
                    useMaterial3: true,
                    colorScheme: const ColorScheme.dark(
                      primary: AppTheme.darkPrimary,
                    ),
                    scaffoldBackgroundColor: AppTheme.darkScaffold,
                    fontFamily: AppStrings.fontFamily,
                    snackBarTheme: const SnackBarThemeData(
                      backgroundColor: AppTheme.darkSurface,
                      contentTextStyle: TextStyle(
                        color: AppTheme.darkSubtext,
                        fontFamily: AppStrings.fontFamily,
                      ),
                    ),
                  ),
          home: const TransferMoneyScreen(),
        );
      },
    );
  }
}
