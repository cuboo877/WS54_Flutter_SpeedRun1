import 'package:flutter/material.dart';
import 'package:ws54_flutter_prac2/page/Home.dart';
import 'package:ws54_flutter_prac2/service/sharedPref.dart';
import 'package:ws54_flutter_prac2/service/sql_service.dart';
import 'package:ws54_flutter_prac2/service/utilities.dart';

import 'login.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void delayNav() async {
    await Future.delayed(const Duration(milliseconds: 500));
    String loggedUserid = await SharedPref.getLoggedUserID();
    if (mounted) {
      if (loggedUserid.isNotEmpty) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => HomePage(userID: loggedUserid)));
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Utilities.showNormalSnackBar(
              context, "歡迎回來!", const Duration(seconds: 3));
        });
      } else {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    delayNav();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        "assets/icon.png",
        width: 200,
        height: 200,
      ),
    );
  }
}
