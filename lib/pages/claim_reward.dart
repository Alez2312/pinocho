// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/confirmation_dialog.dart';
import 'package:pinocho/services/firebase_service_item.dart';
import 'package:pinocho/services/firebase_service_user.dart';

class ClaimRewards extends StatefulWidget {
  const ClaimRewards({Key? key}) : super(key: key);

  static const String RUTA = '/claim_rewards';

  @override
  State<ClaimRewards> createState() => _ClaimRewardsState();
}

class _ClaimRewardsState extends State<ClaimRewards> {
  int? coins;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

// Método para cargar las monedas del usuario.
  Future<void> _loadCoins() async {
    final loadedCoins = await getCoins();
    setState(() {
      coins = loadedCoins;
    });
  }

// Método para mostrar un diálogo de confirmación al reclamar una recompensa.
  Future<void> _showMyDialog(String? titleReward, int requiredCoins, String uid) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Recompensa',
          content: '¿Seguro que quieres reclamar $titleReward?',
        );
      },
    );

    if (result != null && result) {
      if (coins != null && coins! >= requiredCoins) {
        final newCoins = coins! - requiredCoins;
        await updateCoins(newCoins);
        _loadCoins(); // Actualiza las monedas después de reclamar una recompensa
        updateItemStatus(uid, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recompensas'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tus monedas: ',
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                Text(
                  coins.toString(),
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: getAllItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error al cargar las recompensas"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay recompensas"));
                } else {
                  final rewards = snapshot.data!;
                  return ListView.builder(
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      final requiredCoins = reward['requiredCoins'];
                      final canClaim = requiredCoins <= (coins ?? 0);
                      return ListTile(
                        title: Text(reward['name'] ?? ''),
                        subtitle: Text('monedas: $requiredCoins'),
                        trailing: canClaim
                            ? TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.purple),
                                ),
                                onPressed: () {
                                  _showMyDialog(reward['name'], requiredCoins, reward['id']);
                                },
                                child: const Text(
                                  "Reclamar",
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : const Text('Monedas insuficientes'),
                        );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}