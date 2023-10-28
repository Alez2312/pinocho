import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/image_uploader.dart';
import 'package:pinocho/pages/home.dart';
import 'package:pinocho/services/firebase_service_item.dart';

class ItemsPage extends StatefulWidget {
  final Map<String, dynamic>? item;
  const ItemsPage({Key? key, this.item}) : super(key: key);
  static String RUTA = '/item';

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _status = false;
  bool isLoading = false;
  String? _imageUrl;
  String? _itemId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?['name']);
    _descriptionController =
        TextEditingController(text: widget.item?['description']);
    _imageUrl = widget.item?['image'];
    _status = widget.item?['status'] ?? false;
    _itemId = widget.item?['id'] ??
        FirebaseFirestore.instance.collection('items').doc().id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  _saveItem() async {
    if (_formKey.currentState!.validate()) {
      if (_imageUrl == null) {
        // Si no se ha seleccionado una imagen, muestra un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona una imagen.'),
          ),
        );
      } else {
        if (widget.item == null) {
          // Si es nulo, estamos agregando un nuevo personaje
          await addItem(_itemId!, _nameController.text,
              _descriptionController.text, _imageUrl, _status);
        } else {
          // Si no es nulo, estamos modificando un personaje existente
          await updateItem(_itemId!, _nameController.text,
              _descriptionController.text, _imageUrl, _status);
        }
        Navigator.pop(context);
      }
    }
  }

  Widget _buildProfileImage() {
    Size size = MediaQuery.of(context).size;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.network(
              _imageUrl ??
                  'https://campussafetyconference.com/wp-content/uploads/2020/08/iStock-476085198.jpg',
              width: size.width * 0.4,
              height: size.height * 0.2,
              fit: BoxFit.cover,
              key: UniqueKey(),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ImageUploader(
              uid: _itemId!,
              onImageSelected: (image) async {
                setState(() => isLoading = true);
                String? uploadedImageUrl =
                    await uploadImage(_itemId!, image: image);
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
        title: const Text('Agregar Personaje'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              icon: const Icon(Icons.home))
        ],
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
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre",
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
                  labelText: "Descrpción",
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
                onPressed: _saveItem,
                child: const Text("Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
