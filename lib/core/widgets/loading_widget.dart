import 'package:flutter/material.dart';
import 'package:planta_app/core/themes/color_manager.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(
            color: ColorManager.loadingWidgetColor,
          ),
        ),
      ),
    );
  }
}
