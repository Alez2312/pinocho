import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

FirebaseFirestore db = FirebaseFirestore.instance;

FirebaseAuth _auth = FirebaseAuth.instance;

Future<List> getUsers() async {
  List users = [];
  CollectionReference collectionReference = db.collection('users');
  QuerySnapshot queryUsers = await collectionReference.get();

  queryUsers.docs.forEach((document) {
    users.add(document.data());
  });

  return users;
}

// Obtener ID del usuario
String? getUID() {
  return _auth.currentUser?.uid;
}

// Agregar usuario a la base de datos
Future<void> addUser(
    String uid,
    String username,
    String email,
    String selectedGender,
    String country,
    String department,
    String city,
    {String? image}) async {
  FirebaseFirestore.instance.collection('users').doc(uid).set({
    'username': username,
    'email': email,
    'gender': selectedGender,
    'country': country,
    'department': department,
    'city': city,
    'image': image
  },SetOptions(merge: true));
}

// Obtener datos de un usuario específico basado en su id
Future<Map<String, dynamic>> getUserByID(String uid) async {
  DocumentReference docRef = db.collection('users').doc(uid);
  DocumentSnapshot docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    return docSnapshot.data() as Map<String, dynamic>;
  } else {
    return {}; // No existe el usuario
  }
}

// Agregar imagen del usuario
Future<String> uploadDefaultProfileImage(String uid, {File? image}) async {
  final Reference storageRef =
      FirebaseStorage.instance.ref().child('profile_images').child('$uid.jpeg');

  // Cargar la imagen
  if (image == null) {
    // Si no se proporciona una imagen, usa la predeterminada desde los assets
    final ByteData byteData =
        await rootBundle.load('assets/profileDefault.jpeg');
    final Uint8List imageData =
        Uint8List.fromList(byteData.buffer.asUint8List());
    final UploadTask uploadTask = storageRef.putData(imageData);
    await uploadTask.whenComplete(() => {});
  } else {
    // Si se proporciona una imagen, la sube
    final UploadTask uploadTask = storageRef.putFile(image);
    await uploadTask.whenComplete(() => {});
  }
  final String downloadUrl = await storageRef.getDownloadURL();

  await FirebaseFirestore.instance.collection('users').doc(uid).update({
    'image': downloadUrl,
  });

  return downloadUrl;
}
