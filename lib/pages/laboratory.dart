import 'package:flutter/material.dart';
import 'package:pinocho/pages/character/list_character.dart';
import 'package:pinocho/pages/items/list_item.dart';

class LaboratoryPage extends StatelessWidget {
  const LaboratoryPage({super.key});
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
                child: customCard(
                    'Personaje', 'descripción Personaje', Colors.red, () {
              Navigator.pushNamed(context, ListCharacters.RUTA);
            })),
            const SizedBox(width: 16),
            Expanded(
                child:
                    customCard('Item', 'description Item', Colors.pink, () {
              Navigator.pushNamed(context, ListItems.RUTA);})),
          ],
        ),
      ),
    );
  }

  customCard(
      String title, String description, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 200,
        width: 150,
        child: Card(
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
      ),
    );
  }
}
