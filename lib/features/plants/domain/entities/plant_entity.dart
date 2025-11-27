// features/plants/domain/entities/plant_entity.dart
class PlantEntity {
  final String id;
  final String name;
  final String type;
  // final String location;
  final int wateringInterval;
  final DateTime lastWatered;
  final DateTime nextWatering;
  final String? imageUrl;
  final String userId;

  PlantEntity({
    required this.id,
    required this.name,
    required this.type,
    // required this.location,
    required this.wateringInterval,
    required this.lastWatered,
    required this.nextWatering,
    this.imageUrl,
    required this.userId,
  });

  // Méthode pour calculer le prochain arrosage
  DateTime calculateNextWatering() {
    return lastWatered.add(Duration(days: wateringInterval));
  }

  // Vérifier si la plante a besoin d'être arrosée
  bool needsWatering() {
    return DateTime.now().isAfter(nextWatering);
  }
}
