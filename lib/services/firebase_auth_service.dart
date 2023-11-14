// Importación del paquete necesario para la autenticación con Firebase.
import 'package:firebase_auth/firebase_auth.dart';

// Clase FirebaseAuthService para gestionar las operaciones de autenticación con Firebase.
class FirebaseAuthService {
  // Instancia de FirebaseAuth para interactuar con el servicio de autenticación.
  final _auth = FirebaseAuth.instance;

  // Método asincrónico para crear una nueva cuenta de usuario.
  Future<User?> createAccount(String email, String password) async {
    try {
      // Intenta crear un usuario con el email y contraseña proporcionados.
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Retorna el usuario recién creado si la operación es exitosa.
      return credential.user;
    } catch (error) {
      // Captura y registra cualquier error durante la creación de la cuenta.
      print("Error en el servicio createAccount: $error");
    }
    // Retorna null si la creación de la cuenta falla.
    return null;
  }

  // Método asincrónico para iniciar sesión de un usuario.
  Future<User?> login(String email, String password) async {
    try {
      // Intenta iniciar sesión con el email y contraseña proporcionados.
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      // Retorna el usuario si el inicio de sesión es exitoso.
      return credential.user;
    } catch (error) {
      // Captura y registra cualquier error durante el inicio de sesión.
      print("Error en el servicio login: $error");
    }
    // Retorna null si el inicio de sesión falla.
    return null;
  }
}
