// features/plants/data/repositories/plant_repository_impl.dart
import 'package:planta_app/features/plants/data/datasources/plant_data_source.dart';
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'package:planta_app/features/plants/domain/repositories/plant_repository.dart';
import 'package:planta_app/features/plants/data/models/plant_model.dart';

class PlantRepositoryImpl implements PlantRepository {
  final PlantDataSource dataSource;

  PlantRepositoryImpl({required this.dataSource});

  @override
  Future<String> addPlant(PlantEntity plant) async {
    final plantModel = PlantModel.fromEntity(plant);
    return await dataSource.addPlant(plantModel);
  }

  @override
  Future<void> updatePlant(PlantEntity plant) async {
    final plantModel = PlantModel.fromEntity(plant);
    await dataSource.updatePlant(plantModel);
  }

  @override
  Future<void> deletePlant(String plantId) async {
    await dataSource.deletePlant(plantId);
  }

  @override
  Stream<List<PlantEntity>> getPlants(String userId) {
    return dataSource
        .getPlants(userId)
        .map(
          (plantModels) =>
              plantModels.map((model) => model as PlantEntity).toList(),
        );
  }

  @override
  Future<void> waterPlant(String plantId) async {
    await dataSource.waterPlant(plantId);
  }
}
