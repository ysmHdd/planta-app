// features/plants/domain/usecases/get_plants.dart
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'package:planta_app/features/plants/domain/repositories/plant_repository.dart';

class GetPlants {
  final PlantRepository repository;

  GetPlants({required this.repository});

  Stream<List<PlantEntity>> call(String userId) {
    return repository.getPlants(userId);
  }
}
