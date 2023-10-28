import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/image_uploader.dart';
import 'package:pinocho/pages/home.dart';
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _historyController.dispose();
    super.dispose();
  }

  _saveCharacter() async {
  if (_formKey.currentState!.validate()) {
    if (_imageUrl == null) {
      // Si no se ha seleccionado una imagen, muestra un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una imagen.'),
        ),
      );
    } else {
      if (widget.character == null) {
        // Si es nulo, estamos agregando un nuevo personaje
        await addCharacter(_characterId!, _nameController.text,
            _historyController.text, _imageUrl, _status);
      } else {
        // Si no es nulo, estamos modificando un personaje existente
        await updateCharacter(_characterId!, _nameController.text,
            _historyController.text, _imageUrl, _status);
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
