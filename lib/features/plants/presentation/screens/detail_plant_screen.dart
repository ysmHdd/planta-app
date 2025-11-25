// features/plants/presentation/screens/detail_plant_screen.dart
import 'package:flutter/material.dart';

class DetailPlantScreen extends StatelessWidget {
  final String plantId;

  const DetailPlantScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détails de la plante')),
      body: Center(child: Text('Détails pour la plante: $plantId')),
    );
  }
}
