import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified(); 
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    return firebaseUser;
  }

  @override
  Future<bool> isEmailVerified() async {
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    return firebaseUser.isEmailVerified;
  }

  @override
  Future<void> sendEmailVerification() async{
    FirebaseUser firebaseUser = await _firebaseAuth.currentUser();
    firebaseUser.sendEmailVerification();
  }

  @override
  Future<String> signIn(String email, String password) async {
    AuthResult authResult = await _firebaseAuth.signInWithEmailAndPassword(
      email: email, password: password);
    return authResult.user.uid;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  Future<String> signUp(String email, String password) async {
    AuthResult authResult = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email, password: password);
    return authResult.user.uid;
  }
}