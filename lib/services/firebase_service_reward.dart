import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Método para agregar una nueva recompensa para un usuario específico
Future<void> addReward(
    String uid, String title, int requiredCoins, bool status) async {
  try {
    await db.collection('rewards').doc(uid).set({
      'title': title,
      'requiredCoins': requiredCoins,
      'status': status,
    });
  } catch (e) {
    print("Error al agregar los logros: $e");
    throw e;
  }
}

// Método para actualizar una recompensa
Future<void> updateReward(
    String uid, String title, int requiredCoins, bool status) async {
  db.collection('rewards').doc(uid).update({
    'title': title,
    'requiredCoins': requiredCoins,
    'status': status,
  });
}

// Método para obtener todos las recompensas
Future<List<Map<String, dynamic>>> getAllRewards() async {
  QuerySnapshot querySnapshot = await db.collection('rewards').get();
  List<Map<String, dynamic>> items = [];

  for (DocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> ItemData = doc.data() as Map<String, dynamic>;
    ItemData['id'] = doc.id; // Agregar el ID del documento a los datos
    items.add(ItemData);
  }

  return items;
}

// Método para consultar por nombre
Future<Map<String, dynamic>?> getRewardByName(String name) async {
  try {
    final querySnapshot = await db
        .collection('rewards')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final itemDoc = querySnapshot.docs.first;
      return itemDoc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    print('Error al consultar la recompensa por nombre: $e');
    return null;
  }
}

// Método para obtener las recompensas por id
Future<Map<String, dynamic>?> getRewardsByID(String uid) async {
  try {
    DocumentReference docRef = db.collection('rewards').doc(uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>;
    } else {
      return null; // No existe la recompensas
    }
  } catch (e) {
    print("Error al obtener el logro: $e");
    return null;
  }
}

// Método para eliminar un personaje
Future<void> deleteReward(String uid) async {
  db.collection('rewards').doc(uid).delete();
}
