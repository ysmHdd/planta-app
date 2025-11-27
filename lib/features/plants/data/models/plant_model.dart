import 'package:planta_app/features/plants/domain/entities/plant_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlantModel extends PlantEntity {
  PlantModel({
    required super.id,
    required super.name,
    required super.type,
    required super.location,
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
      'location': location,
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
      location: map['location'] ?? '',
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
      location: entity.location,
      wateringInterval: entity.wateringInterval,
      lastWatered: entity.lastWatered,
      nextWatering: entity.nextWatering,
      imageUrl: entity.imageUrl,
      userId: entity.userId,
    );
  }
}
