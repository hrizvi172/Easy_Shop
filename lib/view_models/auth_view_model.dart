import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_info_view_model.dart';

class AuthViewModel {
  final FirebaseAuth _firebaseAuth;

  AuthViewModel(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.idTokenChanges();
  User? CurrentUser() => _firebaseAuth.currentUser;

  Future<User?> getCurrentUser() async {
    if (_firebaseAuth.currentUser != null) {
      return _firebaseAuth.currentUser;
    } else {
      return await signInAnonymously();
    }
  }

  /// Signs in anonymously and returns the resulting User.
  Future<User?> signInAnonymously() async {
    try {
      final UserCredential credential = await _firebaseAuth.signInAnonymously();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      log('Anonymous sign-in failed: ${e.code}');
      return null;
    }
  }

  /// Returns the current user if one exists, otherwise signs in anonymously.
  Future<User?> AnonymousOrCurrent() async {
    if (_firebaseAuth.currentUser != null) {
      return _firebaseAuth.currentUser;
    }
    return await signInAnonymously();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    UserCredential? userCredential;
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        log('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        log('Wrong password provided for that user.');
      }
    }
    return userCredential!;
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String governorate,
    required String address,
  }) async {
    UserCredential? userCredential;
    if (_firebaseAuth.currentUser?.isAnonymous ?? false) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        if (_firebaseAuth.currentUser != null) {
          userCredential = await _firebaseAuth.currentUser!.linkWithCredential(
            credential,
          );
        } else {
          throw Exception('User is null');
        }
        User? user = userCredential.user;
        await UserInfoViewModel(
          uid: user?.uid ?? '',
        ).addUserData(fullName, phoneNumber, governorate, address);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          log('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          log('The account already exists for that email.');
        }
      } catch (e) {
        log(e.toString());
      }
    } else {
      try {
        userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;
        await UserInfoViewModel(
          uid: user?.uid ?? '',
        ).addUserData(fullName, phoneNumber, governorate, address);
        return userCredential;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          log('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          log('The account already exists for that email.');
        }
      } catch (e) {
        log(e.toString());
      }
    }
    return userCredential!;
  }
}
