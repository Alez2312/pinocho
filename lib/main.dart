import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pinocho/pages/character/list_character.dart';
import 'package:pinocho/pages/items/list_item.dart';
import 'package:pinocho/pages/laboratory.dart';
import 'firebase_options.dart';

import 'pages/home.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/welcome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomePage.RUTA,
      routes: {
        WelcomePage.RUTA: (context) => const WelcomePage(),
        LoginPage.RUTA: (context) => const LoginPage(),
        RegisterPage.RUTA: (context) => const RegisterPage(),
        HomePage.RUTA: (context) => const HomePage(),
        LaboratoryPage.RUTA: (context) => const LaboratoryPage(),
        ListCharacters.RUTA: (context) => const ListCharacters(),
        ListItems.RUTA: (context) => const ListItems(),
      },
    );}
}
