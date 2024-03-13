import 'package:flutter/material.dart';
import 'package:ws54_flutter_prac2/constant/style_guide.dart';
import 'package:ws54_flutter_prac2/page/Home.dart';
import 'package:ws54_flutter_prac2/service/sharedPref.dart';
import 'package:ws54_flutter_prac2/service/sql_service.dart';

import '../service/utilities.dart';
import 'Register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController account_controller;
  late TextEditingController password_controller;
  bool isLoading = false;

  bool isAccountValid = false;
  bool isPasswordValid = false;
  bool doAuthWarning = false;
  @override
  void initState() {
    super.initState();
    account_controller = TextEditingController();
    password_controller = TextEditingController();
  }

  @override
  void dispose() {
    account_controller.dispose();
    password_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        body: SingleChildScrollView(
            child: Container(
          width: double.infinity,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icon.png",
                  width: 200,
                  height: 200,
                ),
                const Text(
                  "54 密碼管理系統",
                  style: TextStyle(fontSize: 50),
                ),
                const Text(
                  "登入頁面",
                  style: TextStyle(fontSize: 30),
                ),
                const Text(
                  "帳號",
                  style: TextStyle(fontSize: 30),
                ),
                AccountTextForm(),
                const Text(
                  "帳號",
                  style: TextStyle(fontSize: 30),
                ),
                PasswordTextForm(),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 200,
                  child: TextButton(
                      onPressed: () async {
                        if (isAccountValid && isPasswordValid) {
                          String account = account_controller.text;
                          String password = password_controller.text;
                          LoginResult result =
                              await UserManager.loginReturnResult(
                                  account, password);
                          if (result.success == true) {
                            print("login scuccess!!!");
                            if (mounted) {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => HomePage(
                                          userID: result.userData!.id)));
                              Utilities.showNormalSnackBar(
                                  context,
                                  "歡迎回來! 使用者:${result.userData!.username}",
                                  const Duration(seconds: 3));
                            }
                          } else {
                            setState(() {
                              doAuthWarning = true;
                            });
                          }
                        } else {
                          print("login input not valid . do nothing");
                          Utilities.showNormalSnackBar(
                              context, "請重新輸入資料!", const Duration(seconds: 2));
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: StyleColor.black,
                      ),
                      child: const Text("登入",
                          style: TextStyle(
                              color: StyleColor.white, fontSize: 30))),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "尚未擁有帳號?",
                  style: TextStyle(fontSize: 20),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const RegisterPage())),
                  child: const Text(
                    "註冊",
                    style: TextStyle(fontSize: 30, color: StyleColor.darkBlue),
                  ),
                ),
              ]),
        )),
      ),
    );
  }

  Widget AccountTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: account_controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            doAuthWarning = false;
          });
        },
        validator: (value) {
          if (doAuthWarning) {
            isAccountValid = false;
            return "";
          } else if (value == null || value.trim().isEmpty) {
            isAccountValid = false;
            return "請輸入帳號";
          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
              .hasMatch(value)) {
            isAccountValid = false;
            return "請輸入正確的信箱格式";
          } else {
            isAccountValid = true;
            return null;
          }
        },
        decoration: InputDecoration(
            hintText: "Email",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide:
                    const BorderSide(color: StyleColor.lightgrey, width: 1.5))),
      ),
    );
  }

  Widget PasswordTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: password_controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            doAuthWarning = false;
          });
        },
        validator: (value) {
          if (doAuthWarning) {
            isPasswordValid = false;
            return "錯誤的帳號或密碼";
          } else if (value == null || value.trim().isEmpty) {
            isPasswordValid = false;
            return "請輸入密碼";
          } else {
            isPasswordValid = true;
            return null;
          }
        },
        decoration: InputDecoration(
            hintText: "Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide:
                    const BorderSide(color: StyleColor.lightgrey, width: 1.5))),
      ),
    );
  }
}
