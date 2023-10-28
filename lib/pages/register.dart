import 'package:csc_picker/csc_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinocho/services/firebase_service_user.dart';
import '../services/firebase_auth_service.dart';
import 'home.dart';
import 'login.dart';

class RegisterPage extends StatelessWidget {
  static String RUTA = '/register';

  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Register();
  }
}

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

enum SelectedGender { Masculino, Femenino }

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuthService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  String? countryValue = "";
  String? stateValue = "";
  String? cityValue = "";
  bool _isPasswordVisible = false;
  SelectedGender? _selectedGender = SelectedGender.Masculino;

  @override
  void initState() {
    super.initState();
    _selectedGender = null;
  }

  void _registerAndCreateProfile() async {
    String username = _usernameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String selectedGender = _selectedGender.toString().split('.').last;
    String? country = countryValue;
    String? state = stateValue;
    String? city = cityValue;

    if (state != null) {
      state = state.replaceAll(" Department", "");
    }

    if (_formKey.currentState!.validate()) {
      User? user = await _auth.createAccount(email, password);
      if (user != null) {
        // Usar el UID de Firebase Authentication para agregar el usuario a Firestore
        addUser(
            user.uid, username, email, selectedGender, country!, state!, city!);

        print("Usuario registrado, imagen subida y creado en Firestore");
        Navigator.pushNamed(context, HomePage.RUTA);
      } else {
        print("Error al registrar el usuario");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    TextStyle commonTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 16,
    );
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pinocho3.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        style: commonTextStyle,
                        decoration: InputDecoration(
                          labelText: 'Nombre de usuario',
                          labelStyle: const TextStyle(color: Colors.black),
                          hintText: 'pinocho123',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor ingrese un nombre de usuario';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _emailController,
                        style: commonTextStyle,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          labelStyle: const TextStyle(color: Colors.black),
                          hintText: 'pinocho123@gmail.com',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor ingrese un correo electrónico';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: commonTextStyle,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(color: Colors.black),
                          hintText: 'Contraseña123',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            color: Colors.purple,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Por favor ingrese una contraseña';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10.0),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                Text(
                                  'Género: ',
                                  style: commonTextStyle,
                                ),
                                const SizedBox(width: 10.0),
                                Row(
                                  children: [
                                    Radio(
                                      value: SelectedGender.Masculino,
                                      groupValue: _selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      },
                                    ),
                                    Text('Masculino', style: commonTextStyle),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                      value: SelectedGender.Femenino,
                                      groupValue: _selectedGender,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedGender = value;
                                        });
                                      },
                                    ),
                                    Text('Femenino', style: commonTextStyle),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      CSCPicker(
                        showStates: true,
                        showCities: true,
                        layout: Layout.vertical,
                        flagState: CountryFlag.SHOW_IN_DROP_DOWN_ONLY,
                        dropdownDialogRadius: 10.0,
                        searchBarRadius: 10.0,
                        countryDropdownLabel: 'País',
                        countrySearchPlaceholder: 'Buscar País',
                        stateDropdownLabel: 'Departamento',
                        stateSearchPlaceholder: 'Buscar Departamento',
                        cityDropdownLabel: 'Ciudad',
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
                        selectedItemStyle:
                            const TextStyle(color: Colors.black, fontSize: 18),
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
                      ),
                      const SizedBox(height: 10.0),
                      ElevatedButton(
                        onPressed: () {
                          _registerAndCreateProfile();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Registrar'),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, RegisterPage.RUTA);
                          },
                          child: Column(
                            children: [
                              const Text(
                                '¿Ya tienes cuenta?',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900),
                              ),
                              TextButton(
                                child: const Text(
                                  'Inicia Sesión',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800),
                                ),
                                onPressed: () {
                                  Navigator.pushNamed(context, LoginPage.RUTA);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
