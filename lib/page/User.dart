import 'package:flutter/material.dart';
import 'package:ws54_flutter_prac2/constant/style_guide.dart';
import 'package:ws54_flutter_prac2/page/Home.dart';
import 'package:ws54_flutter_prac2/service/sharedPref.dart';
import 'package:ws54_flutter_prac2/service/sql_service.dart';
import 'package:ws54_flutter_prac2/service/utilities.dart';

import 'login.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.userData});
  final UserData userData;
  @override
  State<StatefulWidget> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late TextEditingController account_controller;
  late TextEditingController password_controller;
  late TextEditingController username_controller;
  late TextEditingController birthday_controller;

  bool isUserNameValid = false;
  bool isBirthdayValid = false;

  bool isAccountValid = false;
  bool isPasswordValid = false;
  bool isEdited = false;
  // bool doAuthWarning = false;

  @override
  void initState() {
    super.initState();
    account_controller = TextEditingController(text: widget.userData.account);
    password_controller = TextEditingController(text: widget.userData.password);
    username_controller = TextEditingController(text: widget.userData.username);
    birthday_controller = TextEditingController(text: widget.userData.birthday);
  }

  @override
  void dispose() {
    username_controller.dispose();
    birthday_controller.dispose();
    account_controller.dispose();
    password_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
          width: double.infinity,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
              "使用者名稱",
              style: TextStyle(fontSize: 30),
            ),
            UserNameTextForm(),
            const Text(
              "生日",
              style: TextStyle(fontSize: 30),
            ),
            BirthdayTextForm(),
            const SizedBox(height: 30),
            logoutButton()
          ])),
      backgroundColor: StyleColor.white,
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), child: topAppBar()),
    );
  }

  Widget AccountTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        controller: account_controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          isEdited = true;
          if (value == null || value.trim().isEmpty) {
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
        validator: (value) {
          isEdited = true;
          if (value == null || value.trim().isEmpty) {
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

  Widget UserNameTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: username_controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          isEdited = true;
          if (value == null || value.trim().isEmpty) {
            isUserNameValid = false;
            return "請輸入稱呼您的名稱";
          } else {
            isUserNameValid = true;
            return null;
          }
        },
        decoration: InputDecoration(
            hintText: "Name",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide:
                    const BorderSide(color: StyleColor.lightgrey, width: 1.5))),
      ),
    );
  }

  Widget BirthdayTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: birthday_controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onTap: () async {
          DateTime? _picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2026));
          if (_picked != null) {
            birthday_controller.text = _picked.toString().split(" ")[0];
            isBirthdayValid = true;
          } else {
            isBirthdayValid = false;
          }
        },
        validator: (value) {
          isEdited = true;
          if (value == null || value.trim().isEmpty) {
            isBirthdayValid = false;
            return "請輸入您的生日";
          } else {
            isBirthdayValid = true;
            return null;
          }
        },
        decoration: InputDecoration(
            hintText: "YYYY-MM-DD",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide:
                    const BorderSide(color: StyleColor.lightgrey, width: 1.5))),
      ),
    );
  }

  Widget topAppBar() {
    return AppBar(
      elevation: 0,
      leading: IconButton(
          onPressed: () {
            if (isEdited) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("返回主畫面"),
                      content: const Text("是否儲存設定?"),
                      actions: [
                        TextButton(
                            onPressed: () async {
                              // ignore: no_leading_underscores_for_local_identifiers
                              UserData _userData = UserData(
                                  id: widget.userData.id,
                                  username: username_controller.text,
                                  account: account_controller.text,
                                  password: password_controller.text,
                                  birthday: birthday_controller.text);
                              await UserDAO.updateUserDataByUserID(_userData);
                              if (mounted) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => HomePage(
                                            userID: widget.userData.id)));
                                Utilities.showNormalSnackBar(
                                    context,
                                    "已變更設定! 使用者:${_userData.username}",
                                    const Duration(seconds: 3));
                              }
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: StyleColor.green),
                            child: const Text(
                              "儲存並返回主畫面",
                              style: TextStyle(color: StyleColor.white),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: StyleColor.darkBlue),
                            child: const Text(
                              "繼續編輯",
                              style: TextStyle(color: StyleColor.white),
                            )),
                        TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage(
                                          userID: widget.userData.id)));
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: StyleColor.red),
                            child: const Text(
                              "放棄",
                              style: TextStyle(color: StyleColor.white),
                            )),
                      ],
                    );
                  });
            } else {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HomePage(userID: widget.userData.id)));
            }
          },
          icon: const Icon(
            Icons.arrow_back,
            color: StyleColor.black,
          )),
      centerTitle: true,
      backgroundColor: StyleColor.white,
      title: const Text(
        "帳戶設置",
        style: TextStyle(color: StyleColor.black),
      ),
    );
  }

  Widget logoutButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45)),
                backgroundColor: StyleColor.white,
                side: const BorderSide(color: StyleColor.red, width: 1.5)),
            onPressed: () {
              SharedPref.cleanLoggedUserID();
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: const Text(
              "登出",
              style: TextStyle(color: StyleColor.red, fontSize: 30),
            )),
      ),
    );
  }
}
