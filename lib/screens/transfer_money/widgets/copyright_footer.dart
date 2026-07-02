import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transaction_app/constants/colors.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_cubit.dart';

class CopyrightFooter extends StatelessWidget {
  const CopyrightFooter({super.key});

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
