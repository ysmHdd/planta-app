// features/plants/presentation/screens/edit_plant_screen.dart
import 'package:flutter/material.dart';

class EditPlantScreen extends StatelessWidget {
  final String plantId;

  const EditPlantScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier la plante')),
      body: Center(child: Text('Édition pour la plante: $plantId')),
    );
  }
}
