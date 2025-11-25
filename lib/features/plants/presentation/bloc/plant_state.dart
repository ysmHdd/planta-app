// features/plants/presentation/blocs/plant_state.dart
import 'package:equatable/equatable.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';

abstract class PlantState extends Equatable {
  const PlantState();

  @override
  List<Object> get props => [];
}

class PlantInitial extends PlantState {}

class PlantLoading extends PlantState {}

class PlantLoaded extends PlantState {
  final List<PlantEntity> plants;
  const PlantLoaded(this.plants);

  @override
  List<Object> get props => [plants];
}

class PlantError extends PlantState {
  final String message;
  const PlantError(this.message);

  @override
  List<Object> get props => [message];
}

class PlantOperationSuccess extends PlantState {
  final String message;
  const PlantOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
