import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/bubble.dart';
import 'package:pinocho/pages/home/home.dart';
import 'package:pinocho/pages/rewards/reward.dart';
import 'package:pinocho/services/firebase_service_reward.dart';
import 'package:pinocho/services/firebase_service_user.dart';

import '../components/confirmation_dialog.dart';

class ListRewards extends StatefulWidget {
  const ListRewards({Key? key}) : super(key: key);

  static const String RUTA = '/list_rewards';

  @override
  State<ListRewards> createState() => _ListRewardsState();
}

class _ListRewardsState extends State<ListRewards> {
  int? coins;

  @override
  void initState() {
    super.initState();
  }

  _showMyDialog(String rewardId) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const ConfirmationDialog(
          title: 'Eliminar',
          content: '¿Estás seguro de que quieres eliminar está recompensa?',
        );
      },
    );

    if (result != null && result) {
      await deleteReward(rewardId);
      setState(() {
        getAllRewards();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Recompensa'),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
          future: getAllRewards(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text("Error al cargar las recompensas"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No hay recompensas"));
            } else {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final reward = snapshot.data![index];
                    return ListTile(
                      title: Text(reward['title']),
                      subtitle: Text('Monedas: ${reward['requiredCoins'].toString()}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                RewardsPage(reward: reward)))
                                    .then((_) {
                                  setState(() {
                                    getAllRewards();
                                  });
                                });
                              }),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showMyDialog(reward['id']);
                            },
                          ),
                        ],
                      ),
                    );
                  });
            }
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RewardsPage()),
          ).then((_) {
            setState(() {
              getAllRewards();
            });
          });
        },
      ),
    );
  }
}

class Reward {
  final String title;
  final int requiredCoins;

  Reward({
    required this.title,
    required this.requiredCoins,
  });
}

class RewardCard extends StatelessWidget {
  final Reward reward;
  final int userCoins;

  const RewardCard({
    Key? key,
    required this.reward,
    required this.userCoins,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        title: Text(reward.title),
        subtitle: Text('Necesitas ${reward.requiredCoins} monedas'),
        trailing: userCoins >= reward.requiredCoins
            ? ElevatedButton(
                onPressed: () {
                  // Implementa la lógica para reclamar la recompensa aquí
                },
                child: const Text('Reclamar'),
              )
            : const Text('No tienes suficientes monedas'),
      ),
    );
  }
}
