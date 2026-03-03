import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();

  static Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<bool> isPhoneAlreadyRegistered(String phone) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  static Future<UserCredential> registerWithEmail(
      String email, String password, String name, String phone) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final displayName = name.isNotEmpty ? name : email.split('@')[0];
    await cred.user?.updateDisplayName(displayName);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({'name': displayName, 'email': email, 'phone': phone});
    return cred;
  }

  static Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      // Su web usa direttamente il popup di Firebase Auth (no client ID richiesto)
      final provider = GoogleAuthProvider();
      return _auth.signInWithPopup(provider);
    }
    // Su mobile usa google_sign_in
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  static Future<void> signOut() async {
    if (!kIsWeb) await _googleSignIn.signOut();
    await _auth.signOut();
  }

  static String localizeError(String code) {
    const messages = {
      'auth/user-not-found': 'Utente non trovato.',
      'user-not-found': 'Utente non trovato.',
      'auth/wrong-password': 'Password errata.',
      'wrong-password': 'Password errata.',
      'auth/email-already-in-use': 'Email già registrata.',
      'email-already-in-use': 'Email già registrata.',
      'auth/weak-password': 'Password troppo corta (min. 6 caratteri).',
      'weak-password': 'Password troppo corta (min. 6 caratteri).',
      'auth/invalid-email': 'Email non valida.',
      'invalid-email': 'Email non valida.',
      'auth/invalid-credential': 'Credenziali non valide.',
      'invalid-credential': 'Credenziali non valide.',
    };
    return messages[code] ?? 'Errore di autenticazione.';
  }
}
