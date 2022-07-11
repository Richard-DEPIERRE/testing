import 'package:aquagymfit/views/homepage.dart';
import 'package:aquagymfit/views/login.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const LoginComponent(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  }

  Future<bool> waitToLoad(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3), () => "");
    // ignore: use_build_context_synchronously
    await Navigator.pushReplacement(context, _createRoute());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object>(
        future: waitToLoad(context),
        builder: (context, snapshot) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(89, 97, 230, 1),
                    Color.fromRGBO(53, 157, 254, 1),
                  ],
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/marque_blanc.png',
                  height: 200,
                ),
              ),
            ),
          );
        });
  }
}
