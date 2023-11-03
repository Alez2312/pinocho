import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Método para agregar un nuevo personaje
Future<void> addCharacter(
    String uid, String name, String history, String? image, List<String> items, bool status) async {
  FirebaseFirestore.instance.collection('characters').doc(uid).set({
    'name': name,
    'history': history,
    'image': image,
    'items': items,
    'status': status,
  });
}

// Método para obtener personaje por id
Future<Map<String, dynamic>?> getCharacterByID(String uid) async {
  try {
    DocumentReference docRef = db.collection('characters').doc(uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>;
    } else {
      return null; // No existe el personaje
    }
  } catch (e) {
    print("Error al obtener el personaje: $e");
    return null;
  }
}

// Método para obtener todos los personajes
Future<List<Map<String, dynamic>>> getAllCharacters() async {
  QuerySnapshot querySnapshot = await db.collection('characters').get();
  List<Map<String, dynamic>> characters = [];

  for (DocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> characterData = doc.data() as Map<String, dynamic>;
    characterData['id'] = doc.id;  // Agregar el ID del documento a los datos
    characters.add(characterData);
  }

  return characters;
}

// Método para eliminar un personaje
Future<void> deleteCharacter(String uid) async {
  FirebaseFirestore.instance.collection('characters').doc(uid).delete();
}

// Método para actualizar un personaje
Future<void> updateCharacter(
    String uid, String name, String history, String? image, List<String> items, bool status) async {
  FirebaseFirestore.instance.collection('characters').doc(uid).update({
    'name': name,
    'history': history,
    'image': image,
    'items': items,
    'status': status,
  });
}

// Método para subir una imagen de un personaje
Future<String?> uploadImage(String uid, {File? image}) async {
  final Reference storageRef = FirebaseStorage.instance
      .ref()
      .child('character_images')
      .child('$uid.jpeg');

  UploadTask uploadTask;
  // Cargar la imagen
  if (image == null) {
    // Si no se proporciona una imagen, usa la predeterminada desde los assets
    final ByteData byteData =
        await rootBundle.load('assets/images/profileDefault.jpeg');
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
Future<Map<String, dynamic>?> getCharacterByName(String name) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('characters')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final characterDoc = querySnapshot.docs.first;
      return characterDoc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  } catch (e) {
    print('Error al consultar el personaje por nombre: $e');
    return null;
  }
}

// Método para obtener la lista de personajes que utilizan un elemento
Future<List<String>> getCharactersUsingItem(String itemId) async {
  List<String> charactersUsingItem = [];

  // Consulta la base de datos para obtener los personajes que utilizan el elemento
  // y agrega sus nombres a la lista charactersUsingItem

  // Ejemplo de consulta (debes adaptarlo a tu estructura de datos)
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('characters')
      .where('items', arrayContains: itemId)
      .get();

  for (QueryDocumentSnapshot doc in querySnapshot.docs) {
    charactersUsingItem.add(doc['name'] as String);
  }

  return charactersUsingItem;
}

// Método para quitar un elemento de los personajes que lo están utilizando
Future<void> removeItemFromCharacters(
    String itemId, List<String> charactersUsingItem) async {
  // Itera sobre la lista de personajes y quita el elemento itemId de sus items

  for (String characterName in charactersUsingItem) {
    // Consulta la base de datos para obtener el personaje por nombre
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('characters')
        .where('name', isEqualTo: characterName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentSnapshot characterDoc = querySnapshot.docs.first;
      String characterId = characterDoc.id;
      
      // Elimina el elemento de la lista de items del personaje
      List<String> items = List.from(characterDoc['items'] as List<dynamic>);
      items.remove(itemId);

      // Actualiza la lista de items del personaje en la base de datos
      await FirebaseFirestore.instance
          .collection('characters')
          .doc(characterId)
          .update({'items': items});
    }
  }
}
