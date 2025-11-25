// features/plants/presentation/screens/add_plant_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_event.dart';

class AddPlantScreen extends StatefulWidget {
  final String userId;

  const AddPlantScreen({super.key, required this.userId});

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _intervalController = TextEditingController(text: '7');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une Plante')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la plante',
                  prefixIcon: Icon(Icons.eco),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type de plante',
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Emplacement',
                  prefixIcon: Icon(Icons.place),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un emplacement';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _intervalController,
                decoration: const InputDecoration(
                  labelText: 'Intervalle d\'arrosage (jours)',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un intervalle';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Veuillez entrer un nombre valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _addPlant,
                child: const Text('Ajouter la Plante'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPlant() {
    if (_formKey.currentState!.validate()) {
      final plant = PlantEntity(
        id: '', // sera généré par Firebase
        name: _nameController.text,
        type: _typeController.text,
        location: _locationController.text,
        wateringInterval: int.parse(_intervalController.text),
        lastWatered: DateTime.now(),
        nextWatering: DateTime.now().add(
          Duration(days: int.parse(_intervalController.text)),
        ),
        userId: widget.userId,
      );

      context.read<PlantBloc>().add(AddPlantEvent(plant));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _locationController.dispose();
    _intervalController.dispose();
    super.dispose();
  }
}
