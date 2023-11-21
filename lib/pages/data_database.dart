// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pinocho/model/field_info.dart';
import 'package:pinocho/pages/home/home.dart';
import 'package:pinocho/services/firebase_service_user.dart';

class FieldsInfoPage extends StatelessWidget {
  final String collection;
  final String documentId;

  static const String RUTA = '/field';

  const FieldsInfoPage({super.key, required this.collection, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campos de la base de datos'),
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
      body: FutureBuilder<List<FieldInfo>>(
        future: getFieldsInfo(collection ,documentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  FieldInfo field = snapshot.data![index];
                  return ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            field.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            field.type,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Text('No hay datos disponibles');
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
