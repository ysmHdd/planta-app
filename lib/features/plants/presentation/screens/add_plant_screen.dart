// features/plants/presentation/screens/add_plant_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_event.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  _AddPlantScreenState createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _intervalController = TextEditingController(text: '7');
  String? _selectedImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une Plante'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // CHAMP IMAGE
              GestureDetector(
                onTap: () {
                  // Optionnel: Tu peux ajouter la sélection d'image plus tard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité image à venir'),
                    ),
                  );
                },
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: _selectedImageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            _selectedImageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la plante',
                  prefixIcon: Icon(Icons.eco, color: Colors.green),
                  border: OutlineInputBorder(),
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
                  prefixIcon: Icon(Icons.category, color: Colors.green),
                  border: OutlineInputBorder(),
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
                controller: _intervalController,
                decoration: const InputDecoration(
                  labelText: 'Intervalle d\'arrosage (jours)',
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.green),
                  border: OutlineInputBorder(),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
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
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: Vous devez être connecté'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final wateringInterval = int.parse(_intervalController.text);

      // CORRECTION : Initialisation correcte pour avoir "À arroser aujourd'hui"
      final plant = PlantEntity(
        id: '',
        name: _nameController.text,
        type: _typeController.text,
        wateringInterval: wateringInterval,
        // CORRECTION : La plante a été arrosée il y a X jours, pas aujourd'hui
        lastWatered: DateTime.now().subtract(Duration(days: wateringInterval)),
        nextWatering: DateTime.now(), // À arroser aujourd'hui
        imageUrl: _selectedImageUrl,
        userId: user.uid,
      );

      print('🌱 DEBUG - Nouvelle plante créée:');
      print('   - Nom: ${plant.name}');
      print('   - Intervalle: ${plant.wateringInterval} jours');
      print('   - LastWatered: ${plant.lastWatered}');
      print('   - NextWatering: ${plant.nextWatering}');
      print('   - Statut: ${plant.wateringStatus}');
      print('   - UserId: ${plant.userId}');

      context.read<PlantBloc>().add(AddPlantEvent(plant));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plante ajoutée avec succès !'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _intervalController.dispose();
    super.dispose();
  }
}
