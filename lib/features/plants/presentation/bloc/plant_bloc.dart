// features/plants/presentation/bloc/plant_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_event.dart';
import 'package:planta_app/features/plants/presentation/bloc/plant_state.dart';
import 'package:planta_app/features/plants/domain/usecases/add_plant.dart';
import 'package:planta_app/features/plants/domain/usecases/delete_plant.dart';
import 'package:planta_app/features/plants/domain/usecases/get_plants.dart';
import 'package:planta_app/features/plants/domain/usecases/update_plant.dart';
import 'package:planta_app/features/plants/domain/usecases/water_plant.dart';

class PlantBloc extends Bloc<PlantEvent, PlantState> {
  final GetPlants getPlants;
  final AddPlant addPlant;
  final UpdatePlant updatePlant;
  final DeletePlant deletePlant;
  final WaterPlant waterPlant;

  String? _currentUserId;

  PlantBloc({
    required this.getPlants,
    required this.addPlant,
    required this.updatePlant,
    required this.deletePlant,
    required this.waterPlant,
  }) : super(PlantInitial()) {
    on<LoadPlantsEvent>(_onLoadPlants);
    on<AddPlantEvent>(_onAddPlant);
    on<UpdatePlantEvent>(_onUpdatePlant);
    on<DeletePlantEvent>(_onDeletePlant);
    on<WaterPlantEvent>(_onWaterPlant);
  }

  Future<void> _onLoadPlants(
    LoadPlantsEvent event,
    Emitter<PlantState> emit,
  ) async {
    _currentUserId = event.userId;
    emit(PlantLoading());

    try {
      await emit.forEach(
        getPlants(event.userId),
        onData: (plants) => PlantLoaded(plants),
        onError: (error, stackTrace) => PlantError('Erreur: $error'),
      );
    } catch (e) {
      emit(PlantError('Erreur lors du chargement: $e'));
    }
  }

  Future<void> _onAddPlant(
    AddPlantEvent event,
    Emitter<PlantState> emit,
  ) async {
    try {
      await addPlant(event.plant);

      final userId = _currentUserId ?? FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        add(LoadPlantsEvent(userId));
      } else {
        emit(
          PlantOperationSuccess(
            'Plante ajoutée - Rechargement manuel nécessaire',
          ),
        );
      }
    } catch (e) {
      emit(PlantError('Erreur lors de l\'ajout: $e'));
    }
  }

  Future<void> _onUpdatePlant(
    UpdatePlantEvent event,
    Emitter<PlantState> emit,
  ) async {
    try {
      await updatePlant(event.plant);

      if (_currentUserId != null) {
        add(LoadPlantsEvent(_currentUserId!));
      }
    } catch (e) {
      emit(PlantError('Erreur lors de la mise à jour: $e'));
    }
  }

  Future<void> _onDeletePlant(
    DeletePlantEvent event,
    Emitter<PlantState> emit,
  ) async {
    try {
      await deletePlant(event.plantId);

      if (_currentUserId != null) {
        add(LoadPlantsEvent(_currentUserId!));
      }
    } catch (e) {
      emit(PlantError('Erreur lors de la suppression: $e'));
    }
  }

  Future<void> _onWaterPlant(
    WaterPlantEvent event,
    Emitter<PlantState> emit,
  ) async {
    try {
      await waterPlant(event.plantId);

      if (_currentUserId != null) {
        add(LoadPlantsEvent(_currentUserId!));
      }
    } catch (e) {
      emit(PlantError('Erreur lors de l\'arrosage: $e'));
    }
  }
}
