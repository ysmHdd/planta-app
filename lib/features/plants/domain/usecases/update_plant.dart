// features/plants/domain/usecases/update_plant.dart
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'package:planta_app/features/plants/domain/repositories/plant_repository.dart';

class UpdatePlant {
  final PlantRepository repository;

  UpdatePlant({required this.repository});

  Future<void> call(PlantEntity plant) {
    return repository.updatePlant(plant);
  }
}
