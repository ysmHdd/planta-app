// features/plants/presentation/widgets/toolbar_action_theme_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planta_app/features/plants/presentation/blocs/switchtheme_cubit.dart';

class ActionThemeButton extends StatelessWidget {
  const ActionThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SwitchthemeCubit, bool>(
      builder: (context, isDarkMode) {
        return IconButton(
          icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          onPressed: () => context.read<SwitchthemeCubit>().toggleTheme(),
        );
      },
    );
  }
}
