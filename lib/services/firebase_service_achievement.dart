import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Método para agregar un nuevo logro (título con estado) para un usuario específico
Future<void> addAchievement(String uid, Map<String, bool> achievements) async {
  try {
    await db.collection('achievements').doc(uid).set({
      'achievements': achievements,
    });
  } catch (e) {
    print("Error al agregar los logros: $e");
    throw e;
  }
}

Future<Map<String, bool>> getAchievements(String uid) async {
  try {
    final doc = await db.collection('achievements').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['achievements'] is Map) {
        return Map<String, bool>.from(data['achievements']);
      }
    }
    return {};
  } catch (e) {
    print("Error al obtener los logros: $e");
    return {};
  }
}

Future<Map<String, bool>> getAchievementsUser(String uid) async {
  try {
    final doc = await FirebaseFirestore.instance.collection('achievements').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['achievements'] is Map) {
        return Map<String, bool>.from(data['achievements']);
      }
    }
    return {};
  } catch (e) {
    print("Error al obtener los logros: $e");
    return {};
  }
}

// Método para obtener logro por id
Future<Map<String, dynamic>?> getAchievementsByID(String uid) async {
  try {
    DocumentReference docRef = db.collection('achievements').doc(uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>;
    } else {
      return null; // No existe el logro
    }
  } catch (e) {
    print("Error al obtener el logro: $e");
    return null;
  }
}

// Método para obtener todos los logros
Future<List<Map<String, dynamic>>> getAllAchievements() async {
  QuerySnapshot querySnapshot = await db.collection('achievements').get();
  List<Map<String, dynamic>> achievements = [];

  for (DocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> achievementsData = doc.data() as Map<String, dynamic>;
    achievementsData['id'] = doc.id; // Agregar el ID del documento a los datos
    achievements.add(achievementsData);
  }

  return achievements;
}

// Método para eliminar un logro
Future<void> deleteAchievements(String uid) async {
  FirebaseFirestore.instance.collection('achievements').doc(uid).delete();
}

// Método para actualizar un logro
Future<void> updateAchievements(String uid, String title, bool status) async {
  FirebaseFirestore.instance.collection('achievements').doc(uid).update({
    'title': title,
    'status': status,
  });
}
