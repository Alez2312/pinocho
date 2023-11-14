import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/bubble.dart';
import 'package:pinocho/services/firebase_service_achievement.dart';
import 'package:pinocho/services/firebase_service_user.dart';

class Achievements extends StatefulWidget {
  const Achievements({Key? key}) : super(key: key);
  static const String RUTA = '/achievements';

  @override
  State<Achievements> createState() => AchievementsState();
}

class AchievementsState extends State<Achievements> {
  Map<String, bool> userAchievements = {};

  @override
  void initState() {
    super.initState();
    loadUserAchievements();
  }

// Método para cargar los logros del usuario.
  Future<void> loadUserAchievements() async {
    final uid = getUID();
    final achievements = await getAchievementsUser(uid!);

    setState(() {
      userAchievements = achievements;
    });
  }

  // Método para generar burbujas decorativas
  List<Widget> generateBubbles() {
    return [
      const Positioned(left: 8, top: 8, child: Bubble(8)),
      const Positioned(left: 16, top: 24, child: Bubble(10)),
      const Positioned(left: 24, top: 12, child: Bubble(12)),
      const Positioned(right: 8, bottom: 8, child: Bubble(8)),
      const Positioned(right: 24, bottom: 16, child: Bubble(10)),
      const Positioned(right: 12, bottom: 24, child: Bubble(12)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Logros'), backgroundColor: Colors.purple),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (userAchievements.isNotEmpty)
                Column(
                  children: userAchievements.entries.map((entry) {
                    final title = entry.key;
                    final isAchieved = entry.value;
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade500,
                              Colors.purple.shade900,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            ...generateBubbles(),
                            ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                isAchieved ? 'Completado' : 'No completado',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                const Text('El usuario no tiene logros.'),
            ],
          ),
        ),
      ),
    );
  }
}
