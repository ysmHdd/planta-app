// features/plants/presentation/blocs/plant_bloc.dart
import 'package:bloc/bloc.dart';
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
    emit(PlantLoading());
    try {
      final plantsStream = getPlants(event.userId);
      await for (final plants in plantsStream) {
        emit(PlantLoaded(plants));
      }
    } catch (e) {
      emit(PlantError('Erreur lors du chargement des plantes: $e'));
    }
  }

  Future<void> _onAddPlant(
    AddPlantEvent event,
    Emitter<PlantState> emit,
  ) async {
    try {
      await addPlant(event.plant);
      emit(PlantOperationSuccess('Plante ajoutée avec succès!'));
      add(LoadPlantsEvent(event.plant.userId)); // Recharger la liste
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
      emit(PlantOperationSuccess('Plante mise à jour!'));
      add(LoadPlantsEvent(event.plant.userId)); // Recharger la liste
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
      emit(PlantOperationSuccess('Plante supprimée!'));
      // Note: On ne peut pas recharger sans userId, peut-être stocker le userId dans le state
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
      emit(PlantOperationSuccess('Plante arrosée!'));
    } catch (e) {
      emit(PlantError('Erreur lors de l\'arrosage: $e'));
    }
  }
}
