import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pinocho/pages/achievements.dart';
import 'package:pinocho/pages/character/list_character.dart';
import 'package:pinocho/pages/history/list_history.dart';
import 'package:pinocho/pages/items/list_item.dart';
import 'package:pinocho/pages/laboratory.dart';
import 'package:pinocho/pages/claim_reward.dart';
import 'package:pinocho/pages/music.dart';
import 'firebase_options.dart';

import 'pages/home/home.dart';
import 'pages/account/login.dart';
import 'pages/account/register.dart';
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
        ListHistory.RUTA:(context) =>  ListHistory(),
        ListItems.RUTA: (context) => const ListItems(),
        Achievements.RUTA:(context) => const Achievements(),
        ClaimRewards.RUTA:(context) => const ClaimRewards(),
        MusicPage.RUTA: (context) => const MusicPage(),
      },
    );}
}
