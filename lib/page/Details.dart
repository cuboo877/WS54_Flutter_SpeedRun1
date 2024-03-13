import 'package:flutter/material.dart';
import 'package:ws54_flutter_prac2/constant/style_guide.dart';
import 'package:ws54_flutter_prac2/service/sql_service.dart';
import 'package:ws54_flutter_prac2/service/utilities.dart';

import 'Home.dart';
import 'Register.dart';
import 'login.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key, required this.account, required this.password});
  final String account;
  final String password;
  @override
  State<StatefulWidget> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late TextEditingController username_controller;
  late TextEditingController birthday_controller;

  bool isUserNameValid = false;
  bool isBirthdayValid = false;

  @override
  void initState() {
    super.initState();
    username_controller = TextEditingController();
    birthday_controller = TextEditingController();
  }

  @override
  void dispose() {
    username_controller.dispose();
    birthday_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60), child: topappbar()),
      body: SingleChildScrollView(
        child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Text(
                  "建立基本使用者資料",
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "使用者名稱",
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 20,
                ),
                UserNameTextForm(),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  "生日",
                  style: TextStyle(fontSize: 30),
                ),
                const SizedBox(
                  height: 20,
                ),
                BirthdayTextForm(),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 200,
                  child: TextButton(
                      onPressed: () async {
                        if (isBirthdayValid == false &&
                            isUserNameValid == false) {
                          print("input not valid . do nothing");
                          Utilities.showNormalSnackBar(
                              context, "請重新輸入資料", const Duration(seconds: 2));
                        } else {
                          String randomId = Utilities.randomID();
                          UserData ud = UserData(
                              id: randomId,
                              username: username_controller.text,
                              account: widget.account,
                              password: widget.password,
                              birthday: birthday_controller.text);
                          RegisterResult result =
                              await UserManager.registerReturnResult(ud);
                          if (result.success == true) {
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (context) => HomePage(
                                          userID: result.userData!.id,
                                        )));
                            Utilities.showNormalSnackBar(
                                context,
                                "您好! 使用者:${result.userData!.username}",
                                const Duration(seconds: 3));
                          } else {
                            Utilities.showNormalSnackBar(context,
                                result.message, const Duration(seconds: 2));
                            print(result.message); //通常不會錯吧(?)
                          }
                        }
                      },
                      child: const Text("開始使用",
                          style:
                              TextStyle(color: StyleColor.white, fontSize: 30)),
                      style: TextButton.styleFrom(
                        backgroundColor: StyleColor.black,
                      )),
                ),
              ],
            )),
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

  Widget topappbar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RegisterPage()));
        },
        icon: const Icon(Icons.arrow_back),
        color: StyleColor.white,
      ),
      title: const Text(
        "即將完成註冊",
        style: TextStyle(color: StyleColor.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: StyleColor.black,
    );
  }
}
