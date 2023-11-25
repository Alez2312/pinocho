import 'package:flutter/material.dart';
import 'package:pinocho/pages/home/home_drawer.dart';
import 'package:pinocho/pages/home/home_history.dart';
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
