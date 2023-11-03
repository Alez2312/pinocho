// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/image_uploader.dart';
import 'package:pinocho/services/firebase_service_history.dart';

class HistoryPage extends StatefulWidget {
  final Map<String, dynamic>? history;
  const HistoryPage({Key? key, this.history}) : super(key: key);
  static String RUTA = '/history';

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  bool _status = false;
  bool isLoading = false;
  String? _imageUrl;
  String? _historyId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.history?['title']);
    _descriptionController =
        TextEditingController(text: widget.history?['description']);
    _imageUrl = widget.history?['image'];
    _status = widget.history?['status'] ?? false;
    _historyId = widget.history?['id'] ??
        FirebaseFirestore.instance.collection('histories').doc().id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Función para guardar un history
  _saveHistory() async {
    if (_formKey.currentState!.validate()) {
      final historyName = _titleController.text;

      if (widget.history == null || historyName != widget.history!['title']) {
        // Si estamos agregando un nuevo history o modificando el nombre
        final historyWithSameName = await getHistoryByTitle(historyName);
        if (historyWithSameName != null) {
          // Ya existe un history con el mismo nombre, mostrar un mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya existe un history con el mismo nombre.'),
            ),
          );
          return; // Salir de la función sin hacer cambios
        }
      }

      // Si se ha seleccionado una imagen, guárdala
      if (_imageUrl != null) {
        if (widget.history == null) {
          // Si estamos agregando un nuevo history
          await addHistory(_historyId!, historyName,
              _descriptionController.text, _imageUrl, _status);
        } else {
          // Si estamos modificando un history existente
          await updateHistory(_historyId!, historyName,
              _descriptionController.text, _imageUrl, _status);
        }
        Navigator.pop(context); // Cerrar la página
      } else {
        // Si no se ha seleccionado una imagen, muestra un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona una imagen.'),
          ),
        );
      }
    }
  }

  // Construir la imagen del history con opción de carga
  Widget _buildProfileImage() {
    Size size = MediaQuery.of(context).size;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.network(
            _imageUrl ??
                'https://img.freepik.com/premium-vector/default-image-icon-vector-missing-picture-page-website-design-mobile-app-no-photo-available_87543-11093.jpg',
            width: size.width,
            height: size.height * 0.2,
            fit: BoxFit.fill,
            key: UniqueKey(),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ImageUploader(
              uid: _historyId!,
              onImageSelected: (image) async {
                setState(() => isLoading = true);
                String? uploadedImageUrl =
                    await uploadImage(_historyId!, image: image);
                if (uploadedImageUrl != null) {
                  setState(() {
                    _imageUrl = uploadedImageUrl;
                    isLoading = false;
                  });
                } else {
                  setState(() => isLoading = false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar History'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildProfileImage(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Titulo",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce una descripción';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Estado"),
                value: _status,
                onChanged: (bool value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.purple)),
                onPressed: _saveHistory,
                child: const Text("Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
// Geppetto, un anciano carpintero, talla una marioneta a partir de un trozo especial de madera que él encuentra. El Nacimineto De Pinocho