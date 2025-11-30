// features/plants/domain/usecases/water_plant.dart
import 'package:planta_app/features/plants/domain/repositories/plant_repository.dart';

class WaterPlant {
  final PlantRepository repository;

  WaterPlant({required this.repository});

  Future<void> call(String plantId) {
    final wateringDate = DateTime.now();
    return repository.waterPlant(plantId, wateringDate);
  }
}
