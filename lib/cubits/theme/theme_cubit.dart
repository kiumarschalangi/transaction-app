import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transaction_app/constants/strings.dart';
import 'package:transaction_app/cubits/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  SharedPreferences? _prefs;

  Future<void> loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final bool isLight = _prefs!.getBool(AppStrings.themePrefsKey) ?? false;
    emit(ThemeState(isLightMode: isLight));
  }

  Future<void> toggleTheme() async {
    final bool newValue = !state.isLightMode;
    await (_prefs ??= await SharedPreferences.getInstance()).setBool(
      AppStrings.themePrefsKey,
      newValue,
    );
    emit(state.copyWith(isLightMode: newValue));
  }
}
