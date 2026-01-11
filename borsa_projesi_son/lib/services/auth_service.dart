
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Şu anki kullanıcıyı getir
  User? get currentUser => _auth.currentUser;

  // Durum değişikliğini dinle (Giriş yaptı mı, çıktı mı?)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Giriş Yap
  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Kayıt Ol
  Future<void> signUp({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Çıkış Yap
  Future<void> signOut() async {
    await _auth.signOut();
  }
}