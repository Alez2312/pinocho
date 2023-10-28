import 'package:flutter/material.dart';
import 'package:pinocho/pages/laboratory.dart';
import 'package:pinocho/pages/profile.dart';
import 'package:pinocho/pages/welcome.dart';
import '../services/firebase_service_user.dart';
import 'components/confirmation_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String RUTA = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? uid;

  @override
  void initState() {
    super.initState();
    uid = getUID();
  }

  _drawerTile(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }

  _userDrawerHeader(Map<String, dynamic> userData) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: CircleAvatar(
        child: ClipOval(
          child: (userData['image'] == null || userData['image'].isEmpty)
              ? Image.asset('assets/profileDefault.jpeg',
                  fit: BoxFit.fitWidth, width: 100)
              : Image.network(userData['image'],
                  fit: BoxFit.fitWidth, width: 100),
        ),
      ),
      accountName: Text(userData['username'],
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      accountEmail: Text(userData['email'],
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      decoration: const BoxDecoration(
        color: Colors.purple,
        image: DecorationImage(
          image: NetworkImage(
              'https://www.broadwayrose.org/wp-content/uploads/2022/11/Pinocchio-banner.jpg'),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Drawer drawerContent() {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>>(
          future: getUserByID(uid!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                var userData = snapshot.data!;
                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _userDrawerHeader(userData),
                    _drawerTile(
                      context,
                      'Ver Perfil',
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: uid!),
                        ),
                      ),
                    ),
                    _drawerTile(
                      context,
                      'Laboratorio',
                      () => Navigator.pushNamed(context, LaboratoryPage.RUTA),
                    ),
                    _drawerTile(
                      context,
                      'Configuración',
                      () => Navigator.pushNamed(context, WelcomePage.RUTA),
                    ),
                    _drawerTile(
                      context,
                      'Salir',
                      () => _showMyDialog(),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: Text("Usuario no encontrado $uid"),
                );
              }
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  _showMyDialog() async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const ConfirmationDialog(
          title: 'Salir',
          content: '¿Estás seguro de que quieres salir de la aplicación?',
        );
      },
    );

    if (result != null && result) {
      Navigator.pushReplacementNamed(context, WelcomePage.RUTA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.purple,
          title: const Text('Bienvenido'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '¡Hola! $uid',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
                onPressed: () {},
                child: const Text('Nada'),
              ),
            ],
          ),
        ),
        drawer: drawerContent());
  }
}
