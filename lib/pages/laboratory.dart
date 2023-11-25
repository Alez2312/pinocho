import 'package:flutter/material.dart';
import 'package:pinocho/pages/character/list_character.dart';
import 'package:pinocho/pages/history/list_history.dart';
import 'package:pinocho/pages/items/list_item.dart';

class LaboratoryPage extends StatelessWidget {
  const LaboratoryPage({Key? key}) : super(key: key);
  static String RUTA = '/laboratory';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratorio'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
// Grid para mostrar opciones en la página del laboratorio.
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          children: [
// Tarjetas personalizadas para diferentes secciones.            
            customCard(
              'Personaje',
              'descripción Personaje',
              Colors.red,
              () {
                Navigator.pushNamed(context, ListCharacters.RUTA);
              },
            ),
            customCard(
              'Item',
              'description Item',
              Colors.pink,
              () {
                Navigator.pushNamed(context, ListItems.RUTA);
              },
            ),
            customCard(
              'Historia',
              'description Historia',
              Colors.purple,
              () {
                Navigator.pushNamed(context, ListHistory.RUTA);
              },
            ),
          ],
        ),
      ),
    );
  }

// Método para crear tarjetas personalizadas.
  Widget customCard(
    String title,
    String description,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
// Diseño de la tarjeta con título, descripción y estilo personalizado.
        elevation: 4,
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
