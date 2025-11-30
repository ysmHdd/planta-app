import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/features/plants/data/models/plant_model.dart';

abstract class PlantDataSource {
  Future<String> addPlant(PlantModel plantModel);
  Future<void> updatePlant(PlantModel plantModel);
  Future<void> deletePlant(String plantId);
  Future<void> waterPlant(String plantId, DateTime wateringDate);
  Stream<List<PlantModel>> getPlants(String userId);
}

class PlantDataSourceImpl implements PlantDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<String> addPlant(PlantModel plantModel) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Utilisateur non connecté');
    }

    final plantWithUser = PlantModel(
      id: plantModel.id,
      name: plantModel.name,
      type: plantModel.type,
      wateringInterval: plantModel.wateringInterval,
      lastWatered: plantModel.lastWatered,
      nextWatering: plantModel.nextWatering,
      imageUrl: plantModel.imageUrl,
      userId: user.uid,
    );

    final docRef = await _firestore
        .collection('plants')
        .add(plantWithUser.toMap());
    return docRef.id;
  }

  @override
  Future<void> updatePlant(PlantModel plantModel) async {
    await _firestore
        .collection('plants')
        .doc(plantModel.id)
        .update(plantModel.toMap());
  }

  @override
  Future<void> deletePlant(String plantId) async {
    await _firestore.collection('plants').doc(plantId).delete();
  }

  @override
  Future<void> waterPlant(String plantId, DateTime wateringDate) async {
    try {
      final doc = await _firestore.collection('plants').doc(plantId).get();
      if (doc.exists) {
        final plantData = doc.data()!;

        final int wateringInterval = plantData['wateringInterval'] ?? 7;
        final DateTime nextWatering = wateringDate.add(
          Duration(days: wateringInterval),
        );

        await _firestore.collection('plants').doc(plantId).update({
          'lastWatered': Timestamp.fromDate(wateringDate),
          'nextWatering': Timestamp.fromDate(nextWatering),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        throw Exception('Plante non trouvée');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'arrosage: $e');
    }
  }

  @override
  Stream<List<PlantModel>> getPlants(String userId) {
    print('🔍 DEBUG - Chargement plantes pour user: $userId');

    return _firestore
        .collection('plants')
        .where('userId', isEqualTo: userId)
        .orderBy('nextWatering')
        .snapshots()
        .map((snapshot) {
          print('📦 DEBUG - ${snapshot.docs.length} plantes trouvées');
          for (var doc in snapshot.docs) {
            final data = doc.data();
            print('   - ${data['name']} (id: ${doc.id})');
            print('     userId: ${data['userId']}');
            print('     nextWatering: ${data['nextWatering']}');
          }
          return snapshot.docs
              .map((doc) => PlantModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }
}
