import 'dart:developer';
import 'dart:io';

import 'package:aquagymfit/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isSignUp = false;

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

  SingleChildScrollView hello() {
    final Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
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
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
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
                          if (isSignUp) {
                            if (_passwordController.text ==
                                _passwordConfirmationController.text) {
                              await AuthService().signUp(
                                  context,
                                  _formKey,
                                  _emailController.text,
                                  _passwordController.text);
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
                            await AuthService().login(
                                context,
                                _formKey,
                                _emailController.text,
                                _passwordController.text);
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
                        padding:
                            const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 0.0),
                        child: Text(
                          (isSignUp) ? "Se connecter" : "Créer un compte",
                          style: const TextStyle(
                              color: Color.fromRGBO(0, 138, 205, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
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
                            onTap: () async {
                              UserCredential? user =
                                  await AuthService().signInWithGoogle();
                              inspect(user);
                            },
                            child: Image.network(
                              "https://upload.wikimedia.org/wikipedia/commons/thumb/5/53/Google_%22G%22_Logo.svg/2048px-Google_%22G%22_Logo.svg.png",
                              height: 45,
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              final user =
                                  await AuthService().signInWithApple();
                              inspect(user);
                            },
                            child: Image.network(
                              (Platform.isIOS)
                                  ? "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/1667px-Apple_logo_black.svg.png"
                                  : "https://cdn-icons-png.flaticon.com/512/124/124010.png",
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
      ),
    );
  }
}
