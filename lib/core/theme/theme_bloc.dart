import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_service.dart';

abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class LoadThemeEvent extends ThemeEvent {}

class ThemeState {
  final bool isDarkMode;
  ThemeState({required this.isDarkMode});
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService themeService;

  ThemeBloc({required this.themeService}) : super(ThemeState(isDarkMode: false)) {
    on<LoadThemeEvent>((event, emit) async {
      final isDark = await themeService.loadThemeMode();
      emit(ThemeState(isDarkMode: isDark));
    });

    on<ToggleThemeEvent>((event, emit) async {
      final newMode = !state.isDarkMode;
      await themeService.saveThemeMode(newMode);
      emit(ThemeState(isDarkMode: newMode));
    });
  }
}
