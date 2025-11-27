// features/plants/domain/entities/plant_entity.dart
class PlantEntity {
  final String id;
  final String name;
  final String type;
  final int wateringInterval;
  final DateTime lastWatered;
  final DateTime nextWatering;
  final String? imageUrl;
  final String userId;

  PlantEntity({
    required this.id,
    required this.name,
    required this.type,
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

  // Vérifier si la plante a besoin d'être arrosée (ancienne méthode)
  bool needsWatering() {
    return DateTime.now().isAfter(nextWatering);
  }

  // NOUVEAU : Statuts d'arrosage détaillés
  WateringStatus get wateringStatus {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWateringDay = DateTime(
      nextWatering.year,
      nextWatering.month,
      nextWatering.day,
    );

    if (nextWateringDay.isBefore(today)) {
      return WateringStatus.overdue;
    } else if (nextWateringDay == today) {
      return WateringStatus.dueToday;
    } else {
      return WateringStatus.watered;
    }
  }

  // NOUVEAU : Calculer les jours de retard
  int get daysOverdue {
    if (wateringStatus != WateringStatus.overdue) return 0;
    final now = DateTime.now();
    return now.difference(nextWatering).inDays;
  }

  // NOUVEAU : Jours restants avant prochain arrosage
  int get daysUntilNextWatering {
    if (wateringStatus != WateringStatus.watered) return 0;
    final now = DateTime.now();
    return nextWatering.difference(now).inDays;
  }
}

// NOUVEAU : Enum des statuts
enum WateringStatus {
  watered, // Déjà arrosée
  dueToday, // À arroser aujourd'hui
  overdue, // En retard
}
