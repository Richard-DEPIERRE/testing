import 'package:aquagymfit/views/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class LoginComponent extends StatefulWidget {
  const LoginComponent({Key? key}) : super(key: key);

  @override
  State<LoginComponent> createState() => _LoginComponentState();
}

class _LoginComponentState extends State<LoginComponent> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isSignUp = false;

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    await secureStorage.write(key: 'user', value: oauthCredential.accessToken);
  }

  signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await secureStorage.write(key: 'user', value: credential.accessToken);
  }

  Future<bool> login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text);
        await secureStorage.write(key: 'user', value: credential.user?.uid);
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
        print(e);
        return false;
      }
    }
    return false;
  }

  Future<bool> signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await secureStorage.write(key: 'user', value: credential.user?.uid);
        login();
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
        print(e);
        return false;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: hello(),
    );
  }

  Column hello() {
    final Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.05),
              child: const Text(
                "AQUA GYMFIT",
                style: TextStyle(
                  fontSize: 36,
                  color: Color.fromRGBO(0, 88, 127, 1),
                  fontWeight: FontWeight.bold,
                  fontFamily: "Blair",
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                "Your Virtual coach",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(2, 148, 207, 1),
                  fontWeight: FontWeight.bold,
                  fontFamily: "Gothic",
                ),
              ),
            ),
          ],
        ),
        Container(
          height: size.height * 0.8,
          // color: Colors.black,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/background_home.png',
              ),
              fit: BoxFit.fitHeight,
              opacity: 0.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null) {
                          return 'Entrez votre email';
                        } else if (value.isEmpty) {
                          return 'Entrez votre email';
                        } else if (!(RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(value))) {
                          return 'Entrez un email valide';
                        } else {
                          return null;
                        }
                      },
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(
                          color: Color.fromRGBO(0, 138, 205, 1),
                          fontWeight: FontWeight.bold,
                        ),
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(0, 138, 205, 1),
                          fontWeight: FontWeight.bold,
                        ),
                        labelText: 'Email',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value == null) {
                          return 'Entrez votre mot de passe';
                        } else if (value.isEmpty) {
                          return 'Entrez votre mot de passe';
                        } else if (value.length < 6) {
                          return 'Mot de passe trop court';
                        } else {
                          return null;
                        }
                      },
                      obscureText: true,
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelStyle: TextStyle(
                          color: Color.fromRGBO(0, 138, 205, 1),
                          fontWeight: FontWeight.bold,
                        ),
                        hintStyle: TextStyle(
                          color: Color.fromRGBO(0, 138, 205, 1),
                          fontWeight: FontWeight.bold,
                        ),
                        labelText: 'Mot de passe',
                      ),
                    ),
                  ),
                  if (isSignUp)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null) {
                            return 'Entrez votre mot de passe';
                          } else if (value.isEmpty) {
                            return 'Entrez votre mot de passe';
                          } else if (value.length < 6) {
                            return 'Mot de passe trop court';
                          } else {
                            return null;
                          }
                        },
                        obscureText: true,
                        controller: _passwordConfirmationController,
                        decoration: const InputDecoration(
                          labelStyle: TextStyle(
                            color: Color.fromRGBO(0, 138, 205, 1),
                            fontWeight: FontWeight.bold,
                          ),
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(0, 138, 205, 1),
                            fontWeight: FontWeight.bold,
                          ),
                          labelText: 'Confirmer le Mot de passe',
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(0, 138, 205, 1),
                        ),
                      ),
                      onPressed: () async {
                        bool res = false;
                        if (isSignUp) {
                          if (_passwordController.text ==
                              _passwordConfirmationController.text) {
                            res = await signUp();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Les mot de passe ne correspondent pas.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } else {
                          res = await login();
                        }
                        if (res) {
                          // ignore: use_build_context_synchronously
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        (isSignUp) ? "Créer son Compte" : "Se Connecter",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                    child: Text(
                      "Mot de passe oublié ?",
                      style: TextStyle(
                          color: Color.fromRGBO(7, 111, 137, 1),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSignUp = !isSignUp;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                      child: Text(
                        (isSignUp) ? "Se connecter" : "Créer un compte",
                        style: const TextStyle(
                            color: Color.fromRGBO(0, 138, 205, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Social Networks
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                    child: Text(
                      "Ou connectez-vous avec",
                      style: TextStyle(
                        color: Color.fromRGBO(7, 111, 137, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            signInWithGoogle();
                          },
                          child: Image.network(
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2048px-Google_%22G%22_Logo.svg.png",
                            height: 45,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            signInWithApple();
                          },
                          child: Image.network(
                            "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png",
                            height: 45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
