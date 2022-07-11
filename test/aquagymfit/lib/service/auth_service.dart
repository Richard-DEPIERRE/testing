import 'dart:developer';

import 'package:aquagymfit/views/home_page.dart';
import 'package:aquagymfit/views/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  final _firebaseAuth = FirebaseAuth.instance;

  // Handle user sign in and sign out
  StreamBuilder handleAuthState() {
    return StreamBuilder(
      stream: _firebaseAuth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }

  // Sign in with google
  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the google sign in flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn(
      scopes: <String>['email'],
    ).signIn();

    if (googleUser == null) {
      return null;
    }

    // Get the google account credentials
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new firebase credential with the google account credentials
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // return the UserCredential
    return await _firebaseAuth.signInWithCredential(credential);
  }

  // Sign in with Facebook
  Future signInWithFacebook() async {
    try {
      final LoginResult facebookLoginResult =
          await FacebookAuth.instance.login();
      final Map<String, dynamic> userData =
          await FacebookAuth.instance.getUserData();
      if (facebookLoginResult.accessToken == null) {
        return;
      }
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(
              facebookLoginResult.accessToken!.token);
      await _firebaseAuth.signInWithCredential(facebookAuthCredential);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseAuth.currentUser!.uid)
          .set({
        'name': userData['name'],
        'email': userData['email'],
        'profile_picture': userData['picture']['data']['url'],
      });
    } catch (e) {
      inspect(e);
    }
  }

  // Sign in with Apple
  Future signInWithApple() async {
    List<Scope> scopes = <Scope>[Scope.email, Scope.fullName];
    // 1. perform the sign-in request
    final result = await TheAppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    // 2. check the result
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential!;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken!),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode!),
        );
        final userCredential =
            await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = userCredential.user!;
        if (scopes.contains(Scope.fullName)) {
          final fullName = appleIdCredential.fullName;
          if (fullName != null &&
              fullName.givenName != null &&
              fullName.familyName != null) {
            final displayName = '${fullName.givenName} ${fullName.familyName}';
            await firebaseUser.updateDisplayName(displayName);
          }
        }
        return firebaseUser;
      case AuthorizationStatus.error:
        throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );

      case AuthorizationStatus.cancelled:
        throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
      default:
        throw UnimplementedError();
    }
  }

  // Sign in with email and password
  Future<bool> login(BuildContext context, GlobalKey<FormState> formKey,
      String email, String password) async {
    if (formKey.currentState!.validate()) {
      try {
        final credential = await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password);
        await storage.write(key: 'user', value: credential.user?.uid);
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Aucun compte n'existe avec cet email."),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Mot de passe incorrect."),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return false;
      } catch (e) {
        inspect(e);
        return false;
      }
    }
    return false;
  }

  // Sign up with email and password
  Future<bool> signUp(BuildContext context, GlobalKey<FormState> formKey,
      String email, String password) async {
    if (formKey.currentState!.validate()) {
      try {
        final credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        await storage.write(key: 'user', value: credential.user?.uid);
        login(context, formKey, email, password);
        return true;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Le mot de passe est trop simple.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Un compte est déjà lié à cet email.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return false;
      } catch (e) {
        inspect(e);
        return false;
      }
    }
    return false;
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn().signOut();
  }
}
