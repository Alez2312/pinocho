import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

// Método para agregar un nuevo item
Future<void> addItem(String uid, String name, String description, String? image,
    int requiredCoins, bool status) async {
  db.collection('items').doc(uid).set({
    'name': name,
    'description': description,
    'requiredCoins': requiredCoins,
    'image': image,
    'status': status,
  });
}

// Método para obtener item por id
Future<Map<String, dynamic>?> getItemByID(String uid) async {
  try {
    DocumentReference docRef = db.collection('items').doc(uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>;
    } else {
      return null; // No existe el item
    }
  } catch (e) {
    print("Error al obtener el item: $e");
    return null;
  }
}

// Método para obtener todos los items
Future<List<Map<String, dynamic>>> getAllItems() async {
  QuerySnapshot querySnapshot = await db.collection('items').get();
  List<Map<String, dynamic>> items = [];

  for (DocumentSnapshot doc in querySnapshot.docs) {
    Map<String, dynamic> ItemData = doc.data() as Map<String, dynamic>;
    ItemData['id'] = doc.id; // Agregar el ID del documento a los datos
    items.add(ItemData);
  }

  return items;
}

// Método para eliminar un item
Future<void> deleteItem(String uid) async {
  db.collection('items').doc(uid).delete();
}

// Método para actualizar un item
Future<void> updateItem(String uid, String name, String description,
    String? image, int requiredCoins, bool status) async {
  db.collection('items').doc(uid).update({
    'name': name,
    'description': description,
    'requiredCoins': requiredCoins,
    'image': image,
    'status': status,
  });
}

// Método para actualizar el estado de un item
Future<void> updateItemStatus(String uid, bool status) async {
  db.collection('items').doc(uid).update({'status': status});
}

// Método para subir una imagen de un item
Future<String?> uploadImage(String uid, {File? image}) async {
  final Reference storageRef =
      FirebaseStorage.instance.ref().child('items_images').child('$uid.jpeg');

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
Future<Map<String, dynamic>?> getItemByName(String name) async {
  try {
    final querySnapshot = await db
        .collection('items')
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
    print('Error al consultar el item por nombre: $e');
    return null;
  }
}

// Método para tomar una lista de IDs de items y devuelve los nombres correspondientes
Future<List<String>> getItemNamesFromIDs(List<dynamic> characterItemIDs) async {
  final itemsCollection = db.collection('items');
  final itemNames = <String>[];

  for (final itemID in characterItemIDs) {
    final itemDoc = await itemsCollection.doc(itemID).get();
    if (itemDoc.exists) {
      final itemName = itemDoc['name'] as String;
      itemNames.add(itemName);
    }
  }

  return itemNames;
}
