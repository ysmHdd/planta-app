// features/plants/presentation/screens/plants_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_state.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_event.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'add_plant_screen.dart';

class PlantsListScreen extends StatelessWidget {
  const PlantsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 50, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Utilisateur non connecté'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final userId = user.uid;
    final plantBloc = context.read<PlantBloc>();
    final currentState = plantBloc.state;

    if (currentState is! PlantLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        plantBloc.add(LoadPlantsEvent(userId));
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Plantes 🌱'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPlantScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<PlantBloc, PlantState>(
        builder: (context, state) {
          if (state is PlantLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlantError) {
            return Center(child: Text(state.message));
          } else if (state is PlantLoaded) {
            final plants = state.plants;

            if (plants.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_florist, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Aucune plante ajoutée',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ajoutez votre première plante !',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                final status = plant.wateringStatus;

                Color getStatusColor() {
                  switch (status) {
                    case WateringStatus.overdue:
                      return Colors.red;
                    case WateringStatus.dueToday:
                      return Colors.orange;
                    case WateringStatus.watered:
                      return Colors.green;
                  }
                }

                String getStatusText() {
                  switch (status) {
                    case WateringStatus.overdue:
                      return 'EN RETARD ⚠️';
                    case WateringStatus.dueToday:
                      return 'À ARROSER AUJOURD\'HUI 💧';
                    case WateringStatus.watered:
                      return 'ARROSÉE ✅';
                  }
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: getStatusColor().withOpacity(0.05),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getStatusColor().withOpacity(0.2),
                      child: Icon(Icons.local_florist, color: getStatusColor()),
                    ),
                    title: Text(
                      plant.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: getStatusColor(),
                      ),
                    ),
                    subtitle: Text(getStatusText()),
                    trailing: status != WateringStatus.watered
                        ? IconButton(
                            icon: Icon(
                              Icons.water_drop,
                              color: getStatusColor(),
                            ),
                            onPressed: () {
                              context.read<PlantBloc>().add(
                                WaterPlantEvent(plant.id),
                              );
                            },
                          )
                        : Icon(Icons.check_circle, color: Colors.green[400]),
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPlantScreen()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
