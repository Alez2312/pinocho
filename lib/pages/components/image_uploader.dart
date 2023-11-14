// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploader extends StatefulWidget {
  final String uid;
  final Function(File image) onImageSelected;

  const ImageUploader({super.key, required this.uid, required this.onImageSelected});

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final picker = ImagePicker();

// Método para mostrar un diálogo con opciones para elegir imagen.
  _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Elegir una opción"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  _optionItem(
                      context, "Galería", ImageSource.gallery, Icons.photo),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  _optionItem(
                      context, "Cámara", ImageSource.camera, Icons.camera_alt),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  TextButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.purple)),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
          );
        });
  }

// Widget para cada opción en el diálogo (galería o cámara).
  _optionItem(
      BuildContext context, String title, ImageSource source, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        _pickImage(context, source);
        Navigator.of(context).pop();
      },
    );
  }

// Método para seleccionar una imagen de la galería o cámara.
  _pickImage(BuildContext context, ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      widget.onImageSelected(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.camera_alt, color: Colors.purple, size: 35),
      onPressed: () => _showChoiceDialog(context),
    );
  }
}
