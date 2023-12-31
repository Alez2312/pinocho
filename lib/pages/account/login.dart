// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinocho/services/firebase_auth_service.dart';
import 'register.dart';

class LoginPage extends StatelessWidget {
  static String RUTA = '/login';

  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Login();
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = FirebaseAuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _emailError = false;
  bool _passwordError = false;
  bool _isPasswordVisible = false;
  bool _isLoggingIn = false;

// Maneja el proceso de inicio de sesión.
  void _handleLogin() async {
    String email = _emailController.text;
    String password = _passwordController.text;
    setState(() {
      _isLoggingIn = true;
    });

// Verifica si los campos están vacíos y actualiza el estado de los errores.
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _emailError = email.isEmpty;
        _passwordError = password.isEmpty;
      });
      setState(() {
        _isLoggingIn = false;
      });
    }

// Intenta iniciar sesión y navega a la página de inicio si tiene éxito.
    User? user = await _auth.login(email, password);

    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
// Muestra un diálogo de error si falla el inicio de sesión.
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Inicio de Sesión Fallido'),
            content: const Text(
                'Credenciales incorrectas. Por favor, inténtalo de nuevo.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
// Obtiene las dimensiones de la pantalla.
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
// Fondo de la pantalla de inicio de sesión.
          Container(
            height: size.height,
            width: size.width,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pinocho.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
// Contenedor para los campos de texto y botones.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon:
                        const Icon(Icons.account_circle, color: Colors.purple),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorText:
                        _emailError ? 'Este campo no puede estar vacío' : null,
                    errorStyle: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock, color: Colors.purple),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorText: _passwordError
                        ? 'Este campo no puede estar vacío'
                        : null,
                    errorStyle: const TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        // Agrega aquí la lógica para la recuperación de contraseña
                      },
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _isLoggingIn ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLoggingIn ? Colors.grey : Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoggingIn
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.white),
                            SizedBox(width: 24),
                            Text(
                              'Iniciando Sesión...',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        )
                      : const Text(
                          'Iniciar Sesión',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, RegisterPage.RUTA);
                        },
                        child: const Text(
                          'Registrarse',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
