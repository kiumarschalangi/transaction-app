import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  const ThemeState({this.isLightMode = false});

  final bool isLightMode;

  ThemeState copyWith({final bool? isLightMode}) {
    return ThemeState(isLightMode: isLightMode ?? this.isLightMode);
  }

  @override
  List<Object> get props => <Object>[isLightMode];
}
