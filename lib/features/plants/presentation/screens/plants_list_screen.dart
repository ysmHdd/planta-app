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
                final needsWatering = plant.needsWatering();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: needsWatering ? Colors.orange[50] : null,
                  child: ListTile(
                    leading: Stack(
                      children: [
                        // IMAGE DE LA PLANTE
                        plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(plant.imageUrl!),
                                radius: 25,
                              )
                            : CircleAvatar(
                                backgroundColor: needsWatering
                                    ? Colors.orange[100]
                                    : Colors.green[100],
                                child: Icon(
                                  Icons.local_florist,
                                  color: needsWatering
                                      ? Colors.orange
                                      : Colors.green,
                                ),
                                radius: 25,
                              ),

                        // INDICATEUR BESOIN D'EAU (PETIT CERCLE ROUGE)
                        if (needsWatering)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      plant.name,
                      style: TextStyle(
                        fontWeight: needsWatering
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Type: ${plant.type}'),
                        const SizedBox(height: 4),
                        Text(
                          needsWatering
                              ? '🌵 Besoin d\'eau !'
                              : 'Prochain arrosage: ${_formatDate(plant.nextWatering)}',
                          style: TextStyle(
                            color: needsWatering
                                ? Colors.red
                                : Colors.grey[600],
                            fontWeight: needsWatering
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: needsWatering
                        ? IconButton(
                            icon: const Icon(
                              Icons.water_drop,
                              color: Colors.blue,
                              size: 30,
                            ),
                            tooltip: 'Arroser la plante',
                            onPressed: () {
                              context.read<PlantBloc>().add(
                                WaterPlantEvent(plant.id),
                              );
                            },
                          )
                        : Icon(
                            Icons.check_circle,
                            color: Colors.green[400],
                            size: 30,
                          ),
                    onTap: () {
                      // Naviguer vers détail de la plante
                      // Navigator.push(...);
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement de vos plantes...'),
                ],
              ),
            );
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
