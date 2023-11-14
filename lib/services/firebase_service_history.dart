import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Método para agregar una nueva historia
Future<void> addHistory(String uid, String title, String description,
    String? greyImageURL, String? colorImageURL, bool status) async {
  db.collection('histories').doc(uid).set({
    'title': title,
    'description': description,
    'greyImageURL': greyImageURL,
    'colorImageURL': colorImageURL,
    'status': status,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

// Método para obtener historia por id
Future<Map<String, dynamic>?> getHistoryByID(String uid) async {
  try {
    DocumentReference docRef = db.collection('histories').doc(uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>;
    } else {
      return null; // No existe la historia
    }
  } catch (e) {
    print("Error al obtener el historia: $e");
    return null;
  }
}

// Método para obtener todas las historias
Future<List<Map<String, dynamic>>> getAllHistories() async {
  QuerySnapshot querySnapshot =
      await db.collection('histories').orderBy("createdAt").get();
  List<Map<String, dynamic>> histories = [];

  for (DocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> characterData = doc.data() as Map<String, dynamic>;
    characterData['id'] = doc.id; // Agregar el ID del documento a los datos
    histories.add(characterData);
  }

  return histories;
}

// Método para eliminar una historia
Future<void> deleteHistory(String uid) async {
  db.collection('histories').doc(uid).delete();
}

// Método para actualizar una historia
Future<void> updateHistory(String uid, String title, String description,
    String? greyImageURL, String? colorImageURL, bool status) async {
  db.collection('histories').doc(uid).update({
    'title': title,
    'description': description,
    'greyImageURL': greyImageURL,
    'colorImageURL': colorImageURL,
    'status': status,
  });
}

// Método para subir una imagen de una historia
Future<String?> uploadImage(String uid,
    {File? image, bool isGreyImage = false}) async {
  // Determina la ruta de almacenamiento basada en el tipo de imagen
  String imagePath = isGreyImage ? 'grey_' : 'color_';
  final Reference storageRef = FirebaseStorage.instance
      .ref()
      .child('histories_images')
      .child('$imagePath$uid.jpeg');

  UploadTask uploadTask;
  // Cargar la imagen
  if (image == null) {
    // Si no se proporciona una imagen, usa la predeterminada desde los assets
    final ByteData byteData =
        await rootBundle.load('assets/images/noImage.png');
    final Uint8List imageData =
        Uint8List.fromList(byteData.buffer.asUint8List());
    uploadTask = storageRef.putData(imageData);
  } else {
    // Si se proporciona una imagen, la sube
    uploadTask = storageRef.putFile(image);
  }

  await uploadTask.whenComplete(() => {});
  return await storageRef.getDownloadURL();
}

// Método para consultar por nombre
Future<Map<String, dynamic>?> getHistoryByTitle(String title) async {
  try {
    final querySnapshot = await db
        .collection('histories')
        .where('title', isEqualTo: title)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final characterDoc = querySnapshot.docs.first;
      return characterDoc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    print('Error al consultar el historia por nombre: $e');
    return null;
  }
}

// Método para actualizar el estado de una historia
Future<void> updateHistoryStatus(String historyId, bool newStatus) async {
  // Aquí actualizas el estado de la historia en Firebase
  await db.collection('histories').doc(historyId).update({
    'status': newStatus,
  });
}
