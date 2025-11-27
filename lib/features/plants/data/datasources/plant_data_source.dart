import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:planta_app/features/plants/data/models/plant_model.dart';

abstract class PlantDataSource {
  Future<String> addPlant(PlantModel plantModel);
  Future<void> updatePlant(PlantModel plantModel);
  Future<void> deletePlant(String plantId);
  Future<void> waterPlant(String plantId);
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

    // CRÉE UNE NOUVELLE PLANTE AVEC LE USER_ID
    final plantWithUser = PlantModel(
      id: plantModel.id,
      name: plantModel.name,
      type: plantModel.type,
      // location: plantModel.location,
      wateringInterval: plantModel.wateringInterval,
      lastWatered: plantModel.lastWatered,
      nextWatering: plantModel.nextWatering,
      imageUrl: plantModel.imageUrl,
      userId: user.uid, // ← LE USER_ID ICI !
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
  Future<void> waterPlant(String plantId) async {
    try {
      // 1. Récupérer la plante actuelle
      final doc = await _firestore.collection('plants').doc(plantId).get();
      if (doc.exists) {
        final plantData = doc.data()!;

        // 2. Calculer les nouvelles dates
        final DateTime now = DateTime.now();
        final int wateringInterval = plantData['wateringInterval'] ?? 7;
        final DateTime nextWatering = now.add(Duration(days: wateringInterval));

        // 3. Mettre à jour la plante
        await _firestore.collection('plants').doc(plantId).update({
          'lastWatered': now,
          'nextWatering': nextWatering,
        });
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'arrosage: $e');
    }
  }

  @override
  Stream<List<PlantModel>> getPlants(String userId) {
    return _firestore
        .collection('plants')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PlantModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }
}
