// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/image_uploader.dart';
import 'package:pinocho/pages/home/home.dart';
import 'package:pinocho/services/firebase_service_character.dart';

class CharactersPage extends StatefulWidget {
  final Map<String, dynamic>? character;
  const CharactersPage({Key? key, this.character}) : super(key: key);
  static String RUTA = '/character';

  @override
  _CharactersPageState createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _historyController;
  bool _status = false;
  bool isLoading = false;
  String? _imageUrl;
  String? _characterId;
  List<String> _selectedItemIds = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.character?['name']);
    _historyController =
        TextEditingController(text: widget.character?['history']);
    _imageUrl = widget.character?['image'];
    _status = widget.character?['status'] ?? false;
    _characterId = widget.character?['id'] ??
        FirebaseFirestore.instance.collection('characters').doc().id;

    // Obtener los IDs de los elementos seleccionados al iniciar la página
    _selectedItemIds = widget.character?['items']?.cast<String>() ?? [];

    // Obtener elementos disponibles al iniciar la página
    _fetchItems();
  }

  // Función para obtener los elementos de la colección "items"
  Future<List<DocumentSnapshot>> _fetchItems() async {
    final itemsSnapshot =
        await FirebaseFirestore.instance.collection('items').get();
    final items = itemsSnapshot.docs;
    return items;
  }

  _handleItemSelection(String itemId) {
    setState(() {
      if (_selectedItemIds.contains(itemId)) {
        // Si ya está seleccionado, lo eliminamos de la lista
        _selectedItemIds.remove(itemId);
      } else {
        // Si no está seleccionado, lo agregamos a la lista
        _selectedItemIds.add(itemId);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  // Función para guardar un personaje
  _saveCharacter() async {
    if (_formKey.currentState!.validate()) {
      final characterName = _nameController.text;

      if (widget.character == null ||
          characterName != widget.character!['name']) {
        // Si estamos agregando un nuevo personaje o modificando el nombre
        final characterWithSameName = await getCharacterByName(characterName);
        if (characterWithSameName != null) {
          // Ya existe un personaje con el mismo nombre, mostrar un mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya existe un personaje con el mismo nombre.'),
            ),
          );
          return; // Salir de la función sin hacer cambios
        }
      }

      // Si se ha seleccionado una imagen, guárdala
      if (_imageUrl != null) {
        if (widget.character == null) {
          // Si estamos agregando un nuevo personaje
          await addCharacter(_characterId!, characterName,
              _historyController.text, _imageUrl, _selectedItemIds, _status);
        } else {
          // Si estamos modificando un personaje existente
          await updateCharacter(_characterId!, characterName,
              _historyController.text, _imageUrl, _selectedItemIds, _status);
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

  // Construir la imagen del personaje con opción de carga
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
              uid: _characterId!,
              onImageSelected: (image) async {
                setState(() => isLoading = true);
                String? uploadedImageUrl =
                    await uploadImage(_characterId!, image: image);
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
                controller: _historyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Historia",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce una historia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  const Text("Items:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: _fetchItems(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Text("Error al cargar los items");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("No hay items disponibles");
                      } else {
                        final items = snapshot.data;

                        // Crear ChoiceChips para cada elemento
                        return Wrap(
                          children: items!.map((item) {
                            final itemId = item.id;
                            final isSelected =
                                _selectedItemIds.contains(itemId);
                            final itemName = item['name'] as String;
                            return ChoiceChip(
                              label: Text(itemName),
                              selected: isSelected,
                              onSelected: (selected) {
                                _handleItemSelection(itemId);
                              },
                              selectedColor: Colors.purple,
                              selectedShadowColor: Colors.purpleAccent,
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ],
              ),
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
                onPressed: _saveCharacter,
                child: const Text("Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
