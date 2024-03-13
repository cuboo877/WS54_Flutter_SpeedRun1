import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ws54_flutter_prac2/page/login.dart';
import 'package:ws54_flutter_prac2/service/sql_service.dart';

import '../constant/style_guide.dart';
import 'Details.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController account_controller;
  late TextEditingController password_controller;
  late TextEditingController confirm_controller;

  bool isAccountValid = false;
  bool isPasswordValid = false;
  bool isConfirmValid = false;
  bool doAuthWarning = false;

  @override
  void initState() {
    super.initState();
    account_controller = TextEditingController();
    password_controller = TextEditingController();
    confirm_controller = TextEditingController();
  }

  @override
  void dispose() {
    account_controller.dispose();
    password_controller.dispose();
    confirm_controller.dispose();
    super.dispose();
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isLoading,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
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
                    "註冊頁面",
                    style: TextStyle(fontSize: 30),
                  ),
                  const Text(
                    "帳號",
                    style: TextStyle(fontSize: 30),
                  ),
                  AccountTextForm(),
                  const Text(
                    "密碼",
                    style: TextStyle(fontSize: 30),
                  ),
                  PasswordTextForm(),
                  const Text(
                    "確認密碼",
                    style: TextStyle(fontSize: 30),
                  ),
                  ConfirmPasswordTextForm(),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    width: 200,
                    child: TextButton(
                        onPressed: () async {
                          String account = account_controller.text;
                          String password = password_controller.text;
                          bool hasRegistered =
                              await UserManager.hasAccountBeenRegistered(
                                  account,
                                  password,
                                  isAccountValid,
                                  isPasswordValid,
                                  isConfirmValid);
                          if (hasRegistered) {
                            print(
                                "has been registered before. back to loginpage");
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                          } else {
                            if (isAccountValid &&
                                isPasswordValid &&
                                isConfirmValid) {
                              print("input valid. go to details page");
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DetailsPage(
                                        account: account,
                                        password: password,
                                      )));
                            } else {
                              print("input not valid. check again");
                              setState(
                                () => doAuthWarning = true,
                              );
                            }
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: StyleColor.black,
                        ),
                        child: const Text("註冊",
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
                        builder: (context) => const LoginPage())),
                    child: const Text(
                      "登入",
                      style:
                          TextStyle(fontSize: 30, color: StyleColor.darkBlue),
                    ),
                  ),
                ],
              )),
        ),
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
            return "";
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

  Widget ConfirmPasswordTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: confirm_controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: (value) {
          setState(() {
            doAuthWarning = false;
          });
        },
        validator: (value) {
          if (doAuthWarning) {
            isConfirmValid = false;
            return "你都沒填好資料 你註冊個der阿";
          } else if (value != password_controller.text) {
            isConfirmValid = false;
            return "請重新確認密碼!";
          } else if (value == null || value.trim().isEmpty) {
            isConfirmValid = false;
            return "請輸入確認您的密碼";
          } else {
            isConfirmValid = true;
            return null;
          }
        },
        decoration: InputDecoration(
            hintText: "Confirm Password",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide:
                    const BorderSide(color: StyleColor.lightgrey, width: 1.5))),
      ),
    );
  }
}
