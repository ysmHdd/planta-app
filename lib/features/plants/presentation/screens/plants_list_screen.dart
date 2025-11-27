// features/plants/presentation/screens/plants_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_state.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_event.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart'; // ← AJOUTEZ CET IMPORT
import 'add_plant_screen.dart';

class PlantsListScreen extends StatelessWidget {
  final String userId;

  const PlantsListScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    // CORRECTION : Charger UNE SEULE FOIS
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
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
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

            // TRIER les plantes : en retard d'abord, puis aujourd'hui, puis arrosées
            plants.sort((a, b) {
              final statusA = a.wateringStatus;
              final statusB = b.wateringStatus;

              if (statusA != statusB) {
                return statusA.index.compareTo(statusB.index);
              }
              return a.nextWatering.compareTo(b.nextWatering);
            });

            // COMPTEURS
            final overdueCount = plants
                .where((p) => p.wateringStatus == WateringStatus.overdue)
                .length;
            final dueTodayCount = plants
                .where((p) => p.wateringStatus == WateringStatus.dueToday)
                .length;
            final wateredCount = plants
                .where((p) => p.wateringStatus == WateringStatus.watered)
                .length;

            if (plants.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              children: [
                // BANDEAU STATISTIQUES
                _buildStatsHeader(overdueCount, dueTodayCount, wateredCount),

                // LISTE DES PLANTES
                Expanded(
                  child: ListView.builder(
                    itemCount: plants.length,
                    itemBuilder: (context, index) {
                      final plant = plants[index];
                      return _buildPlantCard(context, plant);
                    },
                  ),
                ),
              ],
            );
          } else {
            return _buildLoadingState();
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

  // WIDGETS SEPARES P PLUS DE CLARTE
  Widget _buildStatsHeader(int overdue, int dueToday, int watered) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('En retard', overdue, Colors.red),
          _buildStatItem('Aujourd\'hui', dueToday, Colors.orange),
          _buildStatItem('Arrosées', watered, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPlantCard(BuildContext context, PlantEntity plant) {
    // ← Changé en PlantEntity
    final status = plant.wateringStatus;

    // COULEURS selon statut
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

    String getWateringInfo() {
      switch (status) {
        case WateringStatus.overdue:
          final daysLate =
              plant.daysOverdue; // ← Utilise la propriété de l'entité
          return 'Retard de $daysLate jour${daysLate > 1 ? 's' : ''}';
        case WateringStatus.dueToday:
          return 'Dernier arrosage: ${_formatDate(plant.lastWatered)}';
        case WateringStatus.watered:
          return 'Prochain arrosage: ${_formatDate(plant.nextWatering)}';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: getStatusColor().withOpacity(0.05),
      child: ListTile(
        leading: Stack(
          children: [
            // IMAGE
            plant.imageUrl != null && plant.imageUrl!.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(plant.imageUrl!),
                    radius: 25,
                  )
                : CircleAvatar(
                    backgroundColor: getStatusColor().withOpacity(0.2),
                    child: Icon(Icons.local_florist, color: getStatusColor()),
                    radius: 25,
                  ),

            // INDICATEUR STATUT
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: getStatusColor(),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(width: 8, height: 8),
              ),
            ),
          ],
        ),
        title: Text(
          plant.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: getStatusColor(),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${plant.type}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              getStatusText(),
              style: TextStyle(
                color: getStatusColor(),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              getWateringInfo(),
              style: TextStyle(color: Colors.grey[600], fontSize: 11),
            ),
          ],
        ),
        trailing: status != WateringStatus.watered
            ? IconButton(
                icon: Icon(Icons.water_drop, color: getStatusColor(), size: 30),
                tooltip: 'Arroser la plante',
                onPressed: () {
                  context.read<PlantBloc>().add(WaterPlantEvent(plant.id));
                },
              )
            : Icon(Icons.check_circle, color: Colors.green[400], size: 30),
        onTap: () {
          // Naviguer vers détail de la plante
          // Navigator.push(...);
        },
      ),
    );
  }

  // AJOUTEZ CES METHODES MANQUANTES :
  Widget _buildEmptyState() {
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

  Widget _buildLoadingState() {
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

  // DIALOG DE FILTRAGE
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtrer les plantes'),
        content: const Text('Fonctionnalité à venir...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
