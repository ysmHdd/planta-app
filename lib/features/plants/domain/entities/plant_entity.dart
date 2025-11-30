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

  DateTime calculateNextWatering() {
    return lastWatered.add(Duration(days: wateringInterval));
  }

  bool needsWatering() {
    return DateTime.now().isAfter(nextWatering);
  }

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

  int get daysOverdue {
    if (wateringStatus != WateringStatus.overdue) return 0;
    final now = DateTime.now();
    return now.difference(nextWatering).inDays;
  }

  int get daysUntilNextWatering {
    if (wateringStatus != WateringStatus.watered) return 0;
    final now = DateTime.now();
    return nextWatering.difference(now).inDays;
  }
}

enum WateringStatus { watered, dueToday, overdue }
