import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';

abstract class PlantRepository {
  Future<String> addPlant(PlantEntity plant);
  Future<void> updatePlant(PlantEntity plant);
  Future<void> deletePlant(String plantId);
  Future<void> waterPlant(String plantId);
  Stream<List<PlantEntity>> getPlants(String userId);
}
