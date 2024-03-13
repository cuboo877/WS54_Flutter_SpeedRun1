import 'package:flutter/material.dart';
import 'package:ws54_flutter_prac2/service/sql_service.dart';

import '../constant/style_guide.dart';
import '../service/utilities.dart';
import 'Home.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key, required this.userID});
  final String userID;
  @override
  State<StatefulWidget> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  bool isTagValid = false;
  bool isURLValid = false;
  bool isLoginValid = false;
  bool isPasswordValid = false;
  int isFav = 0;

  late TextEditingController tag_controller;
  late TextEditingController url_controller;
  late TextEditingController login_controller;
  late TextEditingController password_controller;

  late TextEditingController custonChars_controller;
  bool hasLowerCase = true;
  bool hasUpperCase = true;
  bool hasSymbol = true;
  bool hasNumber = true;
  int length = 10;
  @override
  void initState() {
    super.initState();
    tag_controller = TextEditingController();
    url_controller = TextEditingController();
    login_controller = TextEditingController();
    password_controller = TextEditingController();
    custonChars_controller = TextEditingController();
  }

  @override
  void dispose() {
    tag_controller.dispose();
    url_controller.dispose();
    login_controller.dispose();
    password_controller.dispose();
    custonChars_controller.dispose();
    super.dispose();
  }

  PasswordData generatePasswordData() {
    return PasswordData(
        id: Utilities.randomID(),
        userID: widget.userID,
        tag: tag_controller.text,
        url: url_controller.text,
        login: login_controller.text,
        password: password_controller.text,
        isFav: isFav);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StyleColor.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: topAppBar(),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          const SizedBox(
            height: 20,
          ),
          const Text(
            "標籤",
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(
            height: 20,
          ),
          setTagTextForm(),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "網址",
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(
            height: 20,
          ),
          setURLTextForm(),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "登入帳號",
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(
            height: 20,
          ),
          setLoginTextForm(),
          const SizedBox(
            height: 20,
          ),
          const Text(
            "密碼",
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(
            height: 20,
          ),
          setPasswordTextForm(),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isFavButton(),
              const SizedBox(
                width: 20,
              ),
              randomPasswordSettingButton()
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 130,
            child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: StyleColor.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(45))),
                onPressed: () async {
                  if (isTagValid &&
                      isURLValid &&
                      isLoginValid &&
                      isPasswordValid) {
                    PasswordDAO.addPasswordData(
                        widget.userID, generatePasswordData());
                    if (mounted) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) =>
                              HomePage(userID: widget.userID)));
                    }
                  } else {
                    Utilities.showNormalSnackBar(
                        context, "錯誤的輸入資料!", const Duration(seconds: 2));
                  }
                },
                child: const Text(
                  "創建",
                  style: TextStyle(color: StyleColor.white, fontSize: 30),
                )),
          )
        ]),
      ),
    );
  }

  Widget randomPasswordSettingButton() {
    return TextButton(
        style: TextButton.styleFrom(backgroundColor: StyleColor.black),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("隨機密碼設定"),
                    content: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text("指定字元"),
                      TextFormField(
                        controller: custonChars_controller,
                        decoration:
                            const InputDecoration(hintText: "ex: cuboo"),
                      ),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: (hasLowerCase),
                        onChanged: (value) => setState(() {
                          hasLowerCase = !hasLowerCase;
                        }),
                        title: const Text("包含小寫字母"),
                      ),
                      const Divider(color: StyleColor.black),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: (hasUpperCase),
                        onChanged: ((value) => setState(() {
                              hasUpperCase = !hasUpperCase;
                            })),
                        title: const Text("包含大寫字母"),
                      ),
                      const Divider(color: StyleColor.black),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: (hasSymbol),
                        onChanged: ((value) => setState(() {
                              hasSymbol = !hasSymbol;
                            })),
                        title: const Text("包含符號"),
                      ),
                      const Divider(color: StyleColor.black),
                      CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        value: (hasNumber),
                        onChanged: ((value) => setState(() {
                              hasNumber = !hasNumber;
                            })),
                        title: const Text("包含數字"),
                      ),
                      const Divider(color: StyleColor.black),
                      Row(
                        children: [
                          Slider(
                              min: 1,
                              max: 16,
                              divisions: 16,
                              value: length.toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  length = value.toInt();
                                });
                              }),
                          Text(length.toString())
                        ],
                      )
                    ]),
                  );
                });
              });
        },
        child: const Text(
          "隨機密碼設定",
          style: TextStyle(color: StyleColor.white, fontSize: 20),
        ));
  }

  Widget isFavButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          minimumSize: const Size(60, 60),
          shape: const CircleBorder(),
          side: const BorderSide(color: StyleColor.red, width: 2),
          backgroundColor: isFav == 1 ? StyleColor.red : StyleColor.white),
      onPressed: () {
        setState(() {
          isFav == 1 ? isFav = 0 : isFav = 1;
        });
      },
      child: isFav == 1
          ? const Icon(
              Icons.favorite,
              color: StyleColor.white,
            )
          : const Icon(Icons.favorite_border_outlined, color: StyleColor.red),
    );
  }

  Widget setTagTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: tag_controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            isTagValid = false;
            return "請輸入標籤";
          } else {
            isTagValid = true;
            return null;
          }
        },
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.tag),
            hintText: "tag",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide:
                    const BorderSide(color: StyleColor.lightgrey, width: 1.5))),
      ),
    );
  }

  Widget setURLTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        controller: url_controller,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            isURLValid = false;
            return "請輸入網址";
          } else {
            isURLValid = true;
            return null;
          }
        },
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.link),
            hintText: "URL",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide:
                    const BorderSide(color: StyleColor.lightgrey, width: 1.5))),
      ),
    );
  }

  Widget setLoginTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: login_controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            isLoginValid = false;
            return "請輸入登入帳號";
          } else {
            isLoginValid = true;
            return null;
          }
        },
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person),
            hintText: "account",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(45),
                borderSide:
                    const BorderSide(color: StyleColor.lightgrey, width: 1.5))),
      ),
    );
  }

  Widget setPasswordTextForm() {
    return SizedBox(
      width: 320,
      child: TextFormField(
        controller: password_controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            isPasswordValid = false;
            return "請輸入密碼";
          } else {
            isPasswordValid = true;
            return null;
          }
        },
        decoration: InputDecoration(
            suffixIcon: IconButton(
              icon: const Icon(Icons.casino),
              onPressed: () {
                setState(() {
                  password_controller.text = Utilities.randomPassword(
                      hasLowerCase,
                      hasUpperCase,
                      hasSymbol,
                      hasNumber,
                      length,
                      custonChars_controller.text);
                });
              },
            ),
            prefixIcon: const Icon(Icons.tag),
            hintText: "Password",
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
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: StyleColor.black,
          )),
      centerTitle: true,
      backgroundColor: StyleColor.white,
      title: const Text(
        "創建您的密碼",
        style: TextStyle(color: StyleColor.black),
      ),
    );
  }
}
