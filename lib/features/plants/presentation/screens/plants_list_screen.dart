import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:planta_app/core/router/routes.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_bloc.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_state.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_event.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';

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

    _tabController = TabController(length: 3, vsync: this);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final plantBloc = context.read<PlantBloc>();

      if (plantBloc.state is! PlantLoaded) {
        plantBloc.add(LoadPlantsEvent(user.uid));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToAddPlant(BuildContext context) {
    context.go(AppRoutes.addPlant);
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

          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actionRequired)
                IconButton(
                  icon: Icon(Icons.opacity, color: statusColor, size: 24),
                  tooltip: 'Marquer comme arrosé',
                  onPressed: () => _waterPlant(context, plant.id),
                )
              else
                Icon(
                  Icons.spa_outlined,
                  color: Colors.green.shade400,
                  size: 24,
                ),

              const SizedBox(width: 4),

              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue, size: 24),
                tooltip: 'Modifier',
                onPressed: () => _navigateToEditPlant(context, plant),
              ),

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Erreur: Utilisateur non connecté'));
    }

    return Scaffold(
      body: Column(
        children: [
          PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TabBar(
              controller: _tabController,
              labelColor:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
              indicatorColor: Colors.green.shade700,
              tabs: const [
                Tab(text: 'Retard'),
                Tab(text: 'Aujourd\'hui'),
                Tab(text: 'Arrosé'),
              ],
            ),
          ),

          Expanded(
            child: BlocBuilder<PlantBloc, PlantState>(
              builder: (context, state) {
                if (state is PlantLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PlantError) {
                  return Center(child: Text('Erreur: ${state.message}'));
                } else if (state is PlantLoaded) {
                  final plants = state.plants;

                  if (plants.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.spa,
                            size: 90,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 24),
                          const Text('Votre jardin est vide !'),
                        ],
                      ),
                    );
                  }

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPlantListByStatus(plants, WateringStatus.overdue),

                      _buildPlantListByStatus(plants, WateringStatus.dueToday),

                      _buildPlantListByStatus(plants, WateringStatus.watered),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddPlant(context),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
