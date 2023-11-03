
import 'package:flutter/material.dart';
import 'package:pinocho/pages/account/profile.dart';
import 'package:pinocho/pages/achievements.dart';
import 'package:pinocho/pages/claim_reward.dart';
import 'package:pinocho/pages/components/confirmation_dialog.dart';
import 'package:pinocho/pages/laboratory.dart';
import 'package:pinocho/pages/settings.dart';
import 'package:pinocho/pages/welcome.dart';

class DrawerContent extends StatelessWidget {
  final Map<String, dynamic> userData;
  final String? uid;

  const DrawerContent({
    Key? key,
    required this.userData,
    required this.uid,
  }) : super(key: key);

  Widget _drawerTile(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }

  UserAccountsDrawerHeader _userDrawerHeader(Map<String, dynamic> userData) {
    return UserAccountsDrawerHeader(
      currentAccountPicture: CircleAvatar(
        child: ClipOval(
          child: (userData['image'] == null || userData['image'].isEmpty)
              ? Image.asset('assets/images/profileDefault.jpeg',
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
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
          _drawerTile(context, 'Laboratorio',
              () => Navigator.pushNamed(context, LaboratoryPage.RUTA)),
          _drawerTile(
              context,
              'Configuración',
              () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()),
                  )),
          _drawerTile(context, 'Logros',
              () => Navigator.pushNamed(context, Achievements.RUTA)),
          _drawerTile(context, 'Recompensas',
              () => Navigator.pushNamed(context, ClaimRewards.RUTA)),
          _drawerTile(
            context,
            'Salir',
            () => _showMyDialogExit(context, ""),
          ),
        ],
      ),
    );
  }

  _showMyDialogExit(BuildContext context, String? historyId) async {
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
}
