// features/plants/data/models/plant_model.dart
import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlantModel extends PlantEntity {
  PlantModel({
    required super.id,
    required super.name,
    required super.type,
    required super.wateringInterval,
    required super.lastWatered,
    required super.nextWatering,
    super.imageUrl,
    required super.userId,
  });

  // Convertir vers Map pour Firebase
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'wateringInterval': wateringInterval,
      'lastWatered': Timestamp.fromDate(lastWatered),
      'nextWatering': Timestamp.fromDate(nextWatering),
      'imageUrl': imageUrl,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Créer depuis Map (depuis Firebase)
  factory PlantModel.fromMap(Map<String, dynamic> map, String id) {
    return PlantModel(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      wateringInterval: map['wateringInterval'] ?? 7,
      lastWatered: (map['lastWatered'] as Timestamp).toDate(),
      nextWatering: (map['nextWatering'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
      userId: map['userId'] ?? '',
    );
  }

  // Convertir Entity en Model
  factory PlantModel.fromEntity(PlantEntity entity) {
    return PlantModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      wateringInterval: entity.wateringInterval,
      lastWatered: entity.lastWatered,
      nextWatering: entity.nextWatering,
      imageUrl: entity.imageUrl,
      userId: entity.userId,
    );
  }

  // NOUVEAU : Méthode pour arroser la plante (retourne une nouvelle instance)
  PlantModel waterPlant() {
    final now = DateTime.now();
    return PlantModel(
      id: id,
      name: name,
      type: type,
      wateringInterval: wateringInterval,
      lastWatered: now,
      nextWatering: now.add(Duration(days: wateringInterval)),
      imageUrl: imageUrl,
      userId: userId,
    );
  }
}
