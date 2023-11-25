// ignore_for_file: must_be_immutable, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/confirmation_dialog.dart';
import 'package:pinocho/services/firebase_service_achievement.dart';
import 'package:pinocho/services/firebase_service_character.dart';
import 'package:pinocho/services/firebase_service_history.dart';
import 'package:pinocho/services/firebase_service_item.dart';
import 'package:pinocho/services/firebase_service_user.dart';

class HistoryList extends StatefulWidget {
  late String uid;

  HistoryList({Key? key, required this.uid}) : super(key: key);

  @override
  _HistoryListState createState() => _HistoryListState();
}

class _HistoryListState extends State<HistoryList> {
  List<Map<String, dynamic>> histories = [];
  int? selectedCharacterIndex;
  int? selectedHistoryIndex;

  @override
  void initState() {
    super.initState();
    widget.uid = getUID()!;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
              return GestureDetector(
                onTap: () {
                  if (history['status']) {
                    _showCharactersDialog(history['title']);
                    setState(() {
                      selectedHistoryIndex = index;
                    });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: history['status']
                          ? NetworkImage(history['colorImageURL'])
                          : NetworkImage(history['greyImageURL']),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      history['title'],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      history['description'],
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    contentPadding: const EdgeInsets.all(16.0),
                    ),
                ),
              );
            },
          );
        }
      },
    );
  }

// Método para mostrar un diálogo con la lista de personajes.
  _showCharactersDialog(String historyTitle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Elige un personaje'),
            content: SizedBox(
              width: double.maxFinite,
              height: 500,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getAllCharacters(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('Error al cargar los personajes');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No hay personajes disponibles');
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final character = snapshot.data![index];
                        final characterItemIDs =
                            character['items'] as List<dynamic>;
                        final isSelected = selectedCharacterIndex == index;
                        final characterstatus = character['status'];
                        return characterstatus
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCharacterIndex = index;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.purple
                                          : Colors.transparent),
                                  child: ListTile(
                                    title: Text(character['name'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20)),
                                    subtitle: FutureBuilder<List<String>>(
                                      future:
                                          getItemNamesFromIDs(characterItemIDs),
                                      builder: (context, itemNamesSnapshot) {
                                        if (itemNamesSnapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        } else {
                                          final itemNames =
                                              itemNamesSnapshot.data!;
                                          return Text(
                                              'Items: ${itemNames.join(", ")}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16));
                                        }
                                      },
                                    ),
                                    leading: Image.network(character['image']),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    );
                  }
                },
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        selectedCharacterIndex != null
                            ? Colors.purple
                            : Colors.grey),
                  ),
                  onPressed: selectedCharacterIndex != null
                      ? () async {
                          _addAchievement(historyTitle);
                          _goToNextHistory();
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('Entrar al mundo'),
                ),
              ),
            ],
          );
        });
      },
    );
  }

// Método para actualizar el estado al seleccionar la próxima historia.
  _goToNextHistory() {
    if (selectedHistoryIndex != null &&
        selectedHistoryIndex! < histories.length - 1) {
      int nextIndex = selectedHistoryIndex! + 1;
      var nextHistoryId = histories[nextIndex]['id'];
      updateHistoryStatus(nextHistoryId, true);
    }
    setState(() {});
  }

// Método para mostrar un diálogo de confirmación antes de eliminar una historia.
  _showMyDialog(String historyId) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Eliminar Historia',
          content: historyId,
        );
      },
    );
    if (result != null && result) {
      await deleteHistory(historyId);
      setState(() {
        getAllHistories();
      });
    }
  }

// Método para añadir logros y actualizar monedas.
  _addAchievement(String historyTitle) async {
    final currentAchievements = await getAchievementsUser(widget.uid);
    final currentCoins = await getCoins() ?? 0;

    if (currentAchievements.containsKey(historyTitle)) {
      final newCoins = currentCoins + 2;
      await updateCoins(newCoins);
    } else {
      currentAchievements[historyTitle] = true;
      await addAchievement(widget.uid, currentAchievements);

      final newCoins = currentCoins + 5;
      await updateCoins(newCoins);
    }
    addAchievement(widget.uid, currentAchievements);
  }
}
