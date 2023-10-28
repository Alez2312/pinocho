import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/confirmation_dialog.dart';
import 'package:pinocho/pages/home.dart';
import 'package:pinocho/pages/items/item.dart';
import 'package:pinocho/services/firebase_service_item.dart';

class ListItems extends StatefulWidget {
  const ListItems({Key? key}) : super(key: key);
  static String RUTA = '/list_items';

  @override
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  @override
  void initState() {
    super.initState();
  }

  _showMyDialog(String itemId) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const ConfirmationDialog(
          title: 'Eliminar Item',
          content: '¿Estás seguro de que quieres eliminar este item?',
        );
      },
    );

    if (result != null && result) {
      await deleteItem(itemId);
      setState(() {
        _fetchItems();
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    return await getAllItems();
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
        future: _fetchItems(),
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
                                    builder: (context) => ItemsPage(
                                        item: item))).then((_) {
                              setState(() {
                                _fetchItems();
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ItemsPage()),
          ).then((_) {
            setState(() {
              _fetchItems();
            });
          });
        },
      ),
    );
  }
}
