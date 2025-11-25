// features/plants/domain/usecases/add_plant.dart
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'package:planta_app/features/plants/domain/repositories/plant_repository.dart';

class AddPlant {
  final PlantRepository repository;

  AddPlant({required this.repository});

  Future<String> call(PlantEntity plant) {
    return repository.addPlant(plant);
  }
}
