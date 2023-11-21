import 'package:flutter/material.dart';
import 'package:pinocho/pages/data_database.dart';
import 'package:pinocho/pages/history.dart';
import 'package:pinocho/pages/home/home_drawer.dart';
import 'package:pinocho/pages/home/home_history.dart';
import 'package:pinocho/services/firebase_service_history.dart';
import 'package:pinocho/services/firebase_service_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String RUTA = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? uid;
  int userCoinValue = 0;

  @override
  void initState() {
    super.initState();
    uid = getUID();
  }

// Método para construir el contenido del Drawer.
  DrawerContent drawerContent(Map<String, dynamic> userData) {
    return DrawerContent(userData: userData, uid: uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Bienvenido'),
        centerTitle: true,
      ),
      body: HistoryList(uid: uid!),
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
                        collection: 'histories',
                        documentId: "fzSgRNB2iV0e3CSeDx5Z"),
                  ),
                );
              }),
          const SizedBox(height: 10),
          FloatingActionButton(
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
        ],
      ),
      drawer: FutureBuilder<Map<String, dynamic>>(
        future: getUserByID(uid!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              var userData = snapshot.data!;
              return drawerContent(userData);
            } else {
              return Center(
                child: Text("Usuario no encontrado $uid"),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
