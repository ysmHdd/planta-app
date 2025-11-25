// features/plants/presentation/screens/plants_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_state.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_event.dart';

import 'add_plant_screen.dart';

class PlantsListScreen extends StatelessWidget {
  final String userId;

  const PlantsListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Plantes 🌱'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPlantScreen(userId: userId),
                ),
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
              return const Center(child: Text('Aucune plante ajoutée yet!'));
            }

            return ListView.builder(
              itemCount: plants.length,
              itemBuilder: (context, index) {
                final plant = plants[index];
                final needsWatering = plant.needsWatering();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: needsWatering ? Colors.orange[50] : null,
                  child: ListTile(
                    leading: Icon(
                      Icons.local_florist,
                      color: needsWatering ? Colors.orange : Colors.green,
                    ),
                    title: Text(plant.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${plant.type}'),
                        Text('Lieu: ${plant.location}'),
                        Text(
                          needsWatering
                              ? '🌵 Besoin d\'eau!'
                              : 'Prochain arrosage: ${_formatDate(plant.nextWatering)}',
                          style: TextStyle(
                            color: needsWatering ? Colors.red : Colors.grey,
                            fontWeight: needsWatering
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    trailing: needsWatering
                        ? IconButton(
                            icon: const Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              // Marquer comme arrosée
                              context.read<PlantBloc>().add(
                                WaterPlantEvent(plant.id),
                              );
                            },
                          )
                        : null,
                    onTap: () {
                      // Naviguer vers détail de la plante
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Chargez vos plantes'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPlantScreen(userId: userId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
