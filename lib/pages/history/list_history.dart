// ignore_for_file: must_be_immutable, library_private_types_in_public_api, prefer_const_constructors_in_immutables, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/confirmation_dialog.dart';
import 'package:pinocho/pages/history/history.dart';
import 'package:pinocho/pages/home/home.dart';
import 'package:pinocho/services/firebase_service_history.dart';
import 'package:pinocho/services/firebase_service_user.dart';

class ListHistory extends StatefulWidget {
  ListHistory({Key? key}) : super(key: key);
  static String RUTA = '/list_histories';

  @override
  _ListHistoryState createState() => _ListHistoryState();
}

class _ListHistoryState extends State<ListHistory> {
  List<Map<String, dynamic>> histories = [];
  int? selectedHistoryIndex;

  @override
  void initState() {
    super.initState();
  }

  // Método para mostrar un diálogo de confirmación antes de eliminar un personaje.
  _showMyDialog(String characterId) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const ConfirmationDialog(
          title: 'Eliminar Historia',
          content: '¿Estás seguro de que quieres eliminar esta historia?',
        );
      },
    );

    if (result != null && result) {
      await deleteHistory(characterId);
      setState(() {
        getAllHistories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de historias'),
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
        future: getAllHistories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar las historias"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay las historias"));
          } else {
            histories = snapshot.data!;
            return ListView.builder(
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final history = histories[index];
                return Column(
                  children: [       
                    ListTile(
                      title: Text(
                        history['title'],
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      leading: Image.network(history['status']
                          ? history['colorImageURL']
                          : history['greyImageURL']),
                      subtitle: Text(
                        history['description'],
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: const TextStyle(
                            color: Colors.black, fontWeight: FontWeight.w500),
                      ),
                      contentPadding: const EdgeInsets.all(16.0),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            color: Colors.orange,
                            icon: const Icon(Icons.edit, size: 35),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryPage(
                                    history: history,
                                  ),
                                ),
                              ).then((_) {
                                setState(() {
                                  getAllHistories();
                                });
                              });
                            },
                          ),
                          IconButton(
                            color: Colors.red,
                            icon: const Icon(Icons.delete, size: 35),
                            onPressed: () {
                              _showMyDialog(history['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.black),
                  ],
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
            MaterialPageRoute(builder: (context) => const HistoryPage()),
          ).then((_) {
            setState(() {
              getAllHistories();
            });
          });
        },
      ),
    );
  }
}
