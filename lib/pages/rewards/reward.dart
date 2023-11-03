// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pinocho/pages/home/home.dart';
import 'package:pinocho/services/firebase_service_reward.dart';

class RewardsPage extends StatefulWidget {
  final Map<String, dynamic>? reward;
  const RewardsPage({Key? key, this.reward}) : super(key: key);
  static String RUTA = '/reward';

  @override
  _RewardsPageState createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _requiredCoinsController;
  bool _status = false;
  bool isLoading = false;
  String? _rewardId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reward?['title']);
    _requiredCoinsController =
        TextEditingController(text: widget.reward?['requiredCoins'].toString());
    _status = widget.reward?['status'] ?? false;
    _rewardId = widget.reward?['id'] ??
        FirebaseFirestore.instance.collection('rewards').doc().id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _requiredCoinsController.dispose();
    super.dispose();
  }

 // Función para guardar una recompensa
_saveReward() async {
  if (_formKey.currentState!.validate()) {
    final titleReward = _titleController.text;
    final coinValue = int.parse(_requiredCoinsController.text);

    if (widget.reward == null || titleReward != widget.reward!['title']) {
      // Si estamos agregando una nueva recompensa o modificando el nombre
      final rewardWithSameName = await getRewardByName(titleReward);
      if (rewardWithSameName != null) {
        // Ya existe una recompensa con el mismo nombre, mostrar un mensaje de error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe una recompensa con el mismo nombre.'),
          ),
        );
      } else {
        // No existe una recompensa con el mismo nombre, podemos guardarla
        if (widget.reward == null) {
          // Si es una nueva recompensa
          await addReward(_rewardId!, titleReward, coinValue, _status);
        } else {
          // Si estamos actualizando una recompensa existente
          await updateReward(_rewardId!, titleReward, coinValue, _status);
        }
        Navigator.pop(context);
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Reward'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Título",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _requiredCoinsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Cantidad para reclamar la recompensa",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, introduce una cantidad';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text("Estado"),
                value: _status,
                onChanged: (bool value) {
                  setState(() {
                    _status = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.purple)),
                onPressed: _saveReward,
                child: const Text("Guardar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
