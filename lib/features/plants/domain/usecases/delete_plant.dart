import 'package:planta_app/features/plants/domain/repositories/plant_repository.dart';

class DeletePlant {
  final PlantRepository repository;

  DeletePlant({required this.repository});

  Future<void> call(String plantId) {
    return repository.deletePlant(plantId);
  }
}
