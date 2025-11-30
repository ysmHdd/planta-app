// features/plants/presentation/screens/edit_plant_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_event.dart';

class EditPlantScreen extends StatefulWidget {
  final PlantEntity plant;
  const EditPlantScreen({super.key, required this.plant});

  @override
  _EditPlantScreenState createState() => _EditPlantScreenState();
}

class _EditPlantScreenState extends State<EditPlantScreen> {
  final _formKey = GlobalKey<FormState>();

  // Déclaration des contrôleurs
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _intervalController;
  late TextEditingController _imageUrlController;

  String? _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    // Initialisation PRE-REMPLIE avec les données existantes de la plante
    _nameController = TextEditingController(text: widget.plant.name);
    _typeController = TextEditingController(text: widget.plant.type);
    _intervalController = TextEditingController(
      text: widget.plant.wateringInterval.toString(),
    );
    _imageUrlController = TextEditingController(text: widget.plant.imageUrl);
    _selectedImageUrl = widget.plant.imageUrl;
  }

  @override
  void dispose() {
    // ⚠️ Bonnes pratiques: Dispose des contrôleurs pour éviter les fuites de mémoire
    _nameController.dispose();
    _typeController.dispose();
    _intervalController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Méthode pour afficher la boîte de dialogue d'entrée d'URL
  void _showUrlInputDialog() {
    final initialUrl = _imageUrlController.text;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Coller l\'URL de l\'image'),
          content: TextField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: 'URL de l\'image (ex: https://...)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Mise à jour de l'aperçu si l'utilisateur modifie l'URL dans la boîte de dialogue
              setState(() {
                _selectedImageUrl = value.isNotEmpty ? value : null;
              });
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Rétablir l'URL originale si Annuler est pressé
                _imageUrlController.text = initialUrl;
                // Recharger l'aperçu pour refléter l'URL d'origine
                setState(() {
                  _selectedImageUrl = initialUrl.isNotEmpty ? initialUrl : null;
                });
                Navigator.pop(context);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Fermer la boîte de dialogue, la valeur du contrôleur est déjà mise à jour
                Navigator.pop(context);
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  // Logique de modification et envoi de l'événement au Bloc
  void _updatePlant() {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur: Utilisateur non connecté.')),
        );
        return;
      }

      final wateringInterval =
          int.tryParse(_intervalController.text) ??
          7; // Valeur par défaut si erreur

      final imageUrl = _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : null;

      // Création de l'entité MODIFIÉE
      final updatedPlant = PlantEntity(
        id: widget.plant.id, // <-- ESSENTIEL : Conserver l'ID original
        name: _nameController.text,
        type: _typeController.text,
        wateringInterval: wateringInterval,
        // Conserver les dates d'arrosage existantes
        lastWatered: widget.plant.lastWatered,
        nextWatering: widget.plant.nextWatering,
        imageUrl: imageUrl,
        userId: user.uid,
      );

      // ENVOI DE L'ÉVÉNEMENT DE MISE À JOUR
      context.read<PlantBloc>().add(UpdatePlantEvent(updatedPlant));

      // Notification de succès et retour à l'écran précédent
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${updatedPlant.name} a été mis à jour.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la Plante'),
        backgroundColor: Colors.blue[700], // Couleur pour la modification
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Aperçu de l'image (si _selectedImageUrl est défini et non vide)
              if (_selectedImageUrl != null && _selectedImageUrl!.isNotEmpty)
                Container(
                  height: 150,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _selectedImageUrl!,
                      fit: BoxFit.cover,
                      // Gestion d'erreur si l'URL n'est pas une image valide
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.red.shade400,
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Champ URL d'image
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'URL de l\'image (optionnel)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.link),
                    onPressed: _showUrlInputDialog,
                  ),
                ),
                onChanged: (value) {
                  // Mise à jour de l'aperçu si l'utilisateur tape directement
                  setState(() {
                    _selectedImageUrl = value.isNotEmpty ? value : null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Champ Nom
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la plante',
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

              // Champ Type
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type (ex: Succulente, Fougère, etc.)',
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

              // Champ Intervalle d'arrosage
              TextFormField(
                controller: _intervalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Intervalle d\'arrosage (en jours)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Veuillez entrer un nombre de jours valide (> 0)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _updatePlant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Enregistrer les Modifications',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
