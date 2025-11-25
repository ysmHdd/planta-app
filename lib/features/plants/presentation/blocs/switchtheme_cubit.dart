// features/plants/presentation/blocs/switchtheme_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

class SwitchthemeCubit extends Cubit<bool> {
  SwitchthemeCubit() : super(false);
  void toggleTheme() => emit(!state);
}
