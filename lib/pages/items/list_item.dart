// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pinocho/pages/data_database.dart';
import 'package:pinocho/pages/home/home.dart';
import 'package:pinocho/pages/items/item.dart';
import 'package:pinocho/services/firebase_service_item.dart';
import 'package:pinocho/services/firebase_service_character.dart';

class ListItems extends StatefulWidget {
  const ListItems({Key? key}) : super(key: key);
  static String RUTA = '/list_items';

  @override
  // ignore: library_private_types_in_public_api
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  @override
  void initState() {
    super.initState();
  }

  _showMyDialog(String itemId) async {
    // Obtener la lista de personajes que están usando este elemento
    List<String> charactersUsingItem = await getCharactersUsingItem(itemId);

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Estás seguro de que quieres eliminar este item?'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (charactersUsingItem.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                        'Este item está siendo utilizado por los siguientes personajes:'),
                    const SizedBox(height: 8),
                    for (String character in charactersUsingItem)
                      Text(character,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // No eliminar el elemento
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                // Eliminar el elemento y quitarlo de los personajes que lo están usando
                await deleteItem(itemId);
                await removeItemFromCharacters(itemId, charactersUsingItem);
                Navigator.of(context).pop(true); // Confirmar la eliminación
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (result != null && result) {
      setState(() {
        getAllItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de items'),
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
        future: getAllItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar items"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay items"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text(item['description']),
                  leading: Image.network(item['image']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ItemsPage(item: item))).then((_) {
                              setState(() {
                                getAllItems();
                              });
                            });
                          }),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showMyDialog(item['id']);
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
              child: const Icon(Icons.info),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FieldsInfoPage(
                        collection: 'items',
                        documentId: "66NzEfZnSXpyrZb1Ftec"),
                  ),
                );
              }),
          const SizedBox(height: 10),
          FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ItemsPage()),
              ).then((_) {
                setState(() {
                  getAllItems();
                });
              });
            },
          ),
        ],
      ),
    );
  }
}
