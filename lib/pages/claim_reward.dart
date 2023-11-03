import 'package:flutter/material.dart';
import 'package:pinocho/pages/components/bubble.dart';
import 'package:pinocho/pages/components/confirmation_dialog.dart';
import 'package:pinocho/pages/rewards/reward.dart';
import 'package:pinocho/services/firebase_service_reward.dart';
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

  Future<void> _loadCoins() async {
    final loadedCoins = await getCoins();
    setState(() {
      coins = loadedCoins;
    });
  }

  Future<void> _showMyDialog(String? titleReward, int requiredCoins) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          title: 'Recompensa',
          content: 'Felicidades has reclamado $titleReward',
        );
      },
    );

    if (result != null && result) {
      if (coins != null && coins! >= requiredCoins) {
        final newCoins = coins! - requiredCoins;
        await updateCoins(newCoins);
        _loadCoins(); // Actualiza las monedas después de reclamar
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
                  'Monedas: ',
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
                  final rewards = snapshot.data!;
                  return ListView.builder(
                    itemCount: rewards.length,
                    itemBuilder: (context, index) {
                      final reward = rewards[index];
                      final requiredCoins = reward['requiredCoins'] as int;
                      final canClaim = requiredCoins <= (coins ?? 0);

                      return ListTile(
                        title: Text(reward['title'] ?? ''),
                        subtitle: Text('$requiredCoins monedas'),
                        trailing: canClaim
                            ? TextButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.blue),
                                ),
                                onPressed: () {
                                  _showMyDialog(reward['title'], requiredCoins);
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
