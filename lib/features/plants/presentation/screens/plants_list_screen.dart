// features/plants/presentation/screens/plants_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_state.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_event.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'add_plant_screen.dart';

class PlantsListScreen extends StatefulWidget {
  const PlantsListScreen({super.key});

  @override
  State<PlantsListScreen> createState() => _PlantsListScreenState();
}

class _PlantsListScreenState extends State<PlantsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialisation du TabController pour 3 onglets
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Méthodes de Navigation et d'Action (Identiques) ---

  void _navigateToAddPlant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPlantScreen()),
    );
  }

  void _navigateToEditPlant(BuildContext context, PlantEntity plant) {
    context.goNamed('edit_plant', extra: plant);
  }

  void _confirmAndDeletePlant(BuildContext context, PlantEntity plant) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer ${plant.name} ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<PlantBloc>().add(DeletePlantEvent(plant.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${plant.name} a été supprimée')),
                );
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _waterPlant(BuildContext context, String plantId) {
    context.read<PlantBloc>().add(WaterPlantEvent(plantId));
  }

  // --- Widget d'Aide pour l'Information de Date (Identique) ---

  Widget _buildDateInfo({
    required IconData icon,
    required String label,
    required DateTime date,
    bool isNext = false,
  }) {
    final dateString = '${date.day}/${date.month}';
    final color = isNext ? Colors.green.shade600 : Colors.grey.shade600;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text.rich(
          TextSpan(
            text: label,
            style: TextStyle(fontSize: 12, color: color),
            children: [
              TextSpan(
                text: dateString,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Widget pour la Carte de la Plante (Remplaçant l'ItemBuilder) ---

  Widget _buildPlantCard(PlantEntity plant) {
    final theme = Theme.of(context);
    final status = plant.wateringStatus;

    Color getStatusColor() {
      switch (status) {
        case WateringStatus.overdue:
          return Colors.red.shade700;
        case WateringStatus.dueToday:
          return Colors.orange.shade700;
        case WateringStatus.watered:
          return Colors.green.shade700;
      }
    }

    String getStatusText() {
      switch (status) {
        case WateringStatus.overdue:
          return 'Urgence : Arrosage en retard';
        case WateringStatus.dueToday:
          return 'Aujourd\'hui : Arrosage nécessaire';
        case WateringStatus.watered:
          return 'Au sec : Arrosé récemment';
      }
    }

    IconData getStatusIcon() {
      switch (status) {
        case WateringStatus.overdue:
          return Icons.warning_amber_rounded;
        case WateringStatus.dueToday:
          return Icons.water_drop;
        case WateringStatus.watered:
          return Icons.check_circle_outline;
      }
    }

    final statusColor = getStatusColor();
    final actionRequired = status != WateringStatus.watered;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: statusColor.withOpacity(actionRequired ? 0.3 : 0.1),
            width: actionRequired ? 1.5 : 0.5,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16.0),
          title: Text(
            plant.name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                getStatusText(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16.0,
                children: [
                  _buildDateInfo(
                    icon: Icons.access_time,
                    label: 'Dernier : ',
                    date: plant.lastWatered,
                  ),
                  _buildDateInfo(
                    icon: Icons.calendar_today,
                    label: 'Prochain : ',
                    date: plant.nextWatering,
                    isNext: true,
                  ),
                ],
              ),
            ],
          ),

          // ⚠️ BOUTONS COMPACTÉS ET CORRIGÉS
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Bouton Arroser/OK
              if (actionRequired)
                IconButton(
                  icon: Icon(
                    Icons.opacity,
                    color: statusColor,
                    size: 24, // Taille réduite
                  ),
                  tooltip: 'Marquer comme arrosé',
                  onPressed: () => _waterPlant(context, plant.id),
                )
              else
                Icon(
                  Icons.spa_outlined,
                  color: Colors.green.shade400,
                  size: 24, // Taille réduite
                ),

              const SizedBox(width: 4), // Espace réduit
              // 2. Bouton Modifier ✏️
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 24),
                tooltip: 'Modifier',
                onPressed: () => _navigateToEditPlant(context, plant),
              ),

              // 3. Bouton Supprimer 🗑️
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 24),
                tooltip: 'Supprimer',
                onPressed: () => _confirmAndDeletePlant(context, plant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget de Liste (Séparé par statut) ---

  Widget _buildPlantListByStatus(
    List<PlantEntity> plants,
    WateringStatus targetStatus,
  ) {
    final filteredPlants = plants
        .where((p) => p.wateringStatus == targetStatus)
        .toList();

    if (filteredPlants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_box_outline_blank,
              size: 50,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              'Aucune plante dans ce statut.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredPlants.length,
      itemBuilder: (context, index) {
        return _buildPlantCard(filteredPlants[index]);
      },
    );
  }

  // --- Widget Principal ---

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // (Code d'erreur de connexion...)
      return const Scaffold(
        body: Center(child: Text('Erreur: Utilisateur non connecté')),
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
        title: const Text('Mes Plantes'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          indicatorColor: Colors.green.shade700,
          tabs: const [
            Tab(text: 'Retard'),
            Tab(text: 'Aujourd\'hui'),
            Tab(text: 'Arrosé'),
          ],
        ),
      ),

      body: BlocBuilder<PlantBloc, PlantState>(
        builder: (context, state) {
          if (state is PlantLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PlantError) {
            return Center(child: Text('Erreur: ${state.message}'));
          } else if (state is PlantLoaded) {
            final plants = state.plants;

            if (plants.isEmpty) {
              // (Écran pour l'état vide)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.spa, size: 90, color: Colors.green.shade300),
                    const SizedBox(height: 24),
                    const Text('Votre jardin est vide !'),
                  ],
                ),
              );
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Onglet 1 : Retard (Overdue)
                _buildPlantListByStatus(plants, WateringStatus.overdue),
                // Onglet 2 : Aujourd'hui (DueToday)
                _buildPlantListByStatus(plants, WateringStatus.dueToday),
                // Onglet 3 : Arrosé (Watered)
                _buildPlantListByStatus(plants, WateringStatus.watered),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPlant(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
