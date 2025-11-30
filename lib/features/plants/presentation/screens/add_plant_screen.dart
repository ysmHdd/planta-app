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

  // Contrôleur pour le nouveau champ URL
  final _imageUrlController = TextEditingController();

  // Utilisé pour l'affichage de l'aperçu
  String? _selectedImageUrl;

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _intervalController.dispose();
    _imageUrlController
        .dispose(); // Ne pas oublier de disposer le nouveau contrôleur
    super.dispose();
  }

  // --- NOUVELLE MÉTHODE : Afficher la boîte de dialogue pour l'URL ---
  void _showUrlInputDialog() {
    final tempController = TextEditingController(
      text: _imageUrlController.text,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Coller l\'URL de l\'image'),
          content: TextField(
            controller: tempController,
            decoration: const InputDecoration(
              labelText: 'URL de l\'image (ex: https://...)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Met à jour l'URL et déclenche la reconstruction pour l'aperçu
                setState(() {
                  _imageUrlController.text = tempController.text;
                  _selectedImageUrl = tempController.text.isNotEmpty
                      ? tempController.text
                      : null;
                });
                Navigator.pop(context);
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une Plante'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        // Ajouter SingleChildScrollView
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- 1. CHAMPS IMAGE (Remplacé par l'aperçu et le bouton) ---
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child:
                        _selectedImageUrl != null &&
                            _selectedImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _selectedImageUrl!,
                              fit: BoxFit.cover,
                              // Gérer le cas où l'URL est invalide
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Text(
                                      'Erreur de chargement de l\'image',
                                      style: TextStyle(color: Colors.red[700]),
                                    ),
                                  ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_search,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aperçu de la photo (Ajouter l\'URL ci-dessous)',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                  ),
                  // Optionnel: Bouton pour effacer l'image
                  if (_selectedImageUrl != null &&
                      _selectedImageUrl!.isNotEmpty)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedImageUrl = null;
                            _imageUrlController.clear();
                          });
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // --- 2. CHAMP TEXTE POUR L'URL ---
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'URL de l\'image (optionnel)',
                  hintText: 'Collez ici le lien de votre image',
                  prefixIcon: const Icon(Icons.link, color: Colors.blueGrey),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed:
                        _showUrlInputDialog, // Ouvre la boîte de dialogue
                  ),
                ),
                onChanged: (value) {
                  // Mettre à jour l'aperçu en temps réel (ou presque)
                  setState(() {
                    _selectedImageUrl = value.isNotEmpty ? value : null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- CHAMPS EXISTANTS ---
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

      // La vérification de l'URL est maintenant basée sur le contrôleur de texte
      final imageUrl = _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : null;

      final plant = PlantEntity(
        id: '',
        name: _nameController.text,
        type: _typeController.text,
        wateringInterval: wateringInterval,
        lastWatered: DateTime.now(),
        nextWatering: DateTime.now().add(Duration(days: wateringInterval)),
        imageUrl: imageUrl, // <-- UTILISATION DE LA NOUVELLE VALEUR
        userId: user.uid,
      );

      print('🌱 DEBUG - Nouvelle plante:');
      print('  - Image URL: ${plant.imageUrl}');
      print('  - LastWatered: ${plant.lastWatered}');

      context.read<PlantBloc>().add(AddPlantEvent(plant));
      Navigator.pop(context);
    }
  }
}
