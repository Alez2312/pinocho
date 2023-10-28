import 'package:flutter/material.dart';
import 'package:pinocho/pages/character/character.dart';
import 'package:pinocho/pages/components/confirmation_dialog.dart';
import 'package:pinocho/pages/home.dart';
import 'package:pinocho/services/firebase_service_character.dart';

class ListCharacters extends StatefulWidget {
  const ListCharacters({Key? key}) : super(key: key);
  static String RUTA = '/list_character';

  @override
  _ListCharactersState createState() => _ListCharactersState();
}

class _ListCharactersState extends State<ListCharacters> {
  @override
  void initState() {
    super.initState();
  }

  _showMyDialog(String characterId) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const ConfirmationDialog(
          title: 'Eliminar Personaje',
          content: '¿Estás seguro de que quieres eliminar este personaje?',
        );
      },
    );

    if (result != null && result) {
      await deleteCharacter(characterId);
      setState(() {
        _fetchCharacters();
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCharacters() async {
    return await getAllCharacters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de personajes'),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCharacters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar personajes"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay personajes"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final character = snapshot.data![index];
                return ListTile(
                  title: Text(character['name']),
                  subtitle: Text(character['history']),
                  leading: Image.network(character['image']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CharactersPage(
                                        character: character))).then((_) {
                              setState(() {
                                _fetchCharacters();
                              });
                            });
                          }),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showMyDialog(character['id']);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CharactersPage()),
          ).then((_) {
            setState(() {
              _fetchCharacters();
            });
          });
        },
      ),
    );
  }
}