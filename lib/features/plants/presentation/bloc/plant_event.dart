// features/plants/presentation/blocs/plant_event.dart
import 'package:equatable/equatable.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';

abstract class PlantEvent extends Equatable {
  const PlantEvent();

  @override
  List<Object> get props => [];
}

class LoadPlantsEvent extends PlantEvent {
  final String userId;
  const LoadPlantsEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddPlantEvent extends PlantEvent {
  final PlantEntity plant;
  const AddPlantEvent(this.plant);

  @override
  List<Object> get props => [plant];
}

class UpdatePlantEvent extends PlantEvent {
  final PlantEntity plant;
  const UpdatePlantEvent(this.plant);

  @override
  List<Object> get props => [plant];
}

class DeletePlantEvent extends PlantEvent {
  final String plantId;
  const DeletePlantEvent(this.plantId);

  @override
  List<Object> get props => [plantId];
}

class WaterPlantEvent extends PlantEvent {
  final String plantId;
  const WaterPlantEvent(this.plantId);

  @override
  List<Object> get props => [plantId];
}
