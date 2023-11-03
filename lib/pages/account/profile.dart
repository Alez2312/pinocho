import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinocho/services/firebase_service_user.dart';

import '../components/image_uploader.dart';

class ProfilePage extends StatefulWidget {
  final String uid;

  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<DocumentSnapshot> _userDoc;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _genderController = TextEditingController();
  String? countryValue = "";
  String? stateValue = "";
  String? cityValue = "";
  bool isEditing = false;
  bool isLoading = false;

  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userDoc =
        FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
    _userDoc.then((doc) {
      var userData = doc.data() as Map<String, dynamic>;
      _nameController.text = userData['username'];
      _emailController.text = userData['email'];
      _genderController.text = userData['gender'];
      countryValue = userData['country'];
      stateValue = userData['department'];
      cityValue = userData['city'];
    });

    setState(() {
      _userDoc =
          FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      isEditing = false;
    });
  }

  _updateProfile() async {
    String? country = countryValue;
    String? state = stateValue;
    String? city = cityValue;

    if (state != null) {
      state = state.replaceAll(" Department", "");
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({
      'username': _nameController.text,
      'gender': _genderController.text,
      'country': country,
      'department': state,
      'city': city,
    });

    setState(() {
      _userDoc =
          FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      isEditing = !isEditing;
    });
  }

  TextStyle styleTextFormField() {
    return const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    );
  }

  customTextFormField(TextEditingController controller, String label,
      {bool isEditable = true}) {
    return TextFormField(
      enabled: isEditable && isEditing,
      controller: controller,
      style: styleTextFormField(),
      decoration: InputDecoration(
        labelText: label,
        border: isEditable && isEditing
            ? const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)))
            : InputBorder.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.cancel_outlined : Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          )
        ],
      ),
      body: bodyContent(),
    );
  }

  FutureBuilder<DocumentSnapshot<Object?>> bodyContent() {
    Size size = MediaQuery.of(context).size;
    return FutureBuilder<DocumentSnapshot>(
      future: _userDoc,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (!snapshot.hasData) {
            return const Center(child: Text('Usuario no encontrado'));
          }
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                _buildProfileImage(size, userData),
                const SizedBox(height: 20),
                customTextFormField(_nameController, 'Nombre de usuario'),
                customTextFormField(_emailController, 'Correo electrónico',
                    isEditable: false),
                customTextFormField(_genderController, 'Género',
                    isEditable: false),
                ..._buildFormFields(userData),
                if (isEditing) _buildSaveButton(),
              ],
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  _buildProfileImage(Size size, Map<String, dynamic> userData) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: (userData['image'] == null || userData['image'].isEmpty)
                ? Image.asset(
                    'assets/images/profileDefault.jpeg',
                    fit: BoxFit.fitWidth,
                    width: size.width * 0.4,
                  )
                : Image.network(
                    userData['image'],
                    fit: BoxFit.fitWidth,
                    height: size.height * 0.2,
                  ),
          ),
          if (isEditing)
            Positioned(
              right: 0,
              bottom: 0,
              child: ImageUploader(
                uid: widget.uid,
                onImageSelected: (image) async {
                  setState(() => isLoading = true);
                  String newImageUrl =
                      await uploadDefaultProfileImage(widget.uid, image: image);
                  setState(() {
                    isLoading = false;
                    userData['image'] = newImageUrl;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  _buildFormFields(Map<String, dynamic> userData) {
    if (isEditing) {
      return [
        CSCPicker(
          showStates: true,
          showCities: true,
          layout: Layout.vertical,
          flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
          dropdownDialogRadius: 10.0,
          searchBarRadius: 10.0,
          countryDropdownLabel: '${userData['country']}',
          countrySearchPlaceholder: 'Buscar País',
          stateDropdownLabel: '${userData['department']}',
          stateSearchPlaceholder: 'Buscar Departamento',
          cityDropdownLabel: '${userData['city']}',
          citySearchPlaceholder: 'Buscar Ciudad',
          dropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1.0),
            color: Colors.white,
          ),
          disabledDropdownDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          selectedItemStyle: const TextStyle(color: Colors.black, fontSize: 18),
          dropdownHeadingStyle: const TextStyle(
            color: Colors.black,
            fontSize: 27,
            fontWeight: FontWeight.bold,
          ),
          onCountryChanged: (value) {
            if (mounted) {
              setState(() {
                countryValue = value;
              });
            }
          },
          onStateChanged: (value) {
            if (mounted) {
              setState(() {
                stateValue = value ?? "";
              });
            }
          },
          onCityChanged: (value) {
            if (mounted) {
              setState(() {
                cityValue = value ?? "";
              });
            }
          },
        )
      ];
    }
    return [
      customTextFormField(
          TextEditingController(text: userData['country']), 'País',
          isEditable: false),
      const SizedBox(height: 20),
      customTextFormField(
          TextEditingController(text: userData['department']), 'Departamento',
          isEditable: false),
      const SizedBox(height: 20),
      customTextFormField(
          TextEditingController(text: userData['city']), 'Ciudad',
          isEditable: false),
    ];
  }

  _buildSaveButton() {
    return TextButton(
      onPressed: _updateProfile,
      style: TextButton.styleFrom(
        backgroundColor: Colors.purple,
        padding: const EdgeInsets.all(10),
      ),
      child:
          const Text("Guardar Cambios", style: TextStyle(color: Colors.white)),
    );
  }
}
