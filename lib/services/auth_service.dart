
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Instancia de Firebase Authentication.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Instancia de Cloud Firestore.
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registrar un usuario nuevo.
  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Crear la cuenta en Firebase Authentication.
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Obtener el identificador único generado por Firebase.
    final uid = credential.user!.uid;

    // Guardar los datos adicionales del usuario en Firestore.
    await _db.collection('users').doc(uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // Iniciar sesión con correo y contraseña.
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Cerrar la sesión actual.
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Enviar correo para recuperar la contraseña.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email.trim(),
    );
  }

  // Escuchar los cambios en la sesión del usuario.
  Stream<User?> get authStateChanges {
    return _auth.authStateChanges();
  }
}
