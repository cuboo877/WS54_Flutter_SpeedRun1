import 'package:flutter/material.dart';
import 'package:ws54_flutter_prac2/constant/style_guide.dart';
import 'package:ws54_flutter_prac2/page/Add.dart';
import 'package:ws54_flutter_prac2/page/Edit.dart';
import 'package:ws54_flutter_prac2/service/sql_service.dart';
import 'package:ws54_flutter_prac2/service/utilities.dart';

import '../service/sharedPref.dart';
import 'Edit.dart';
import 'User.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.userID});
  final String userID;
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserData userData =
      UserData(id: "", username: "", account: "", password: "", birthday: "");
  List<PasswordData> passwordDataList = [];

  //For search
  late TextEditingController tag_cotroller;
  late TextEditingController url_cotroller;
  late TextEditingController login_cotroller;
  late TextEditingController password_cotroller;
  late TextEditingController id_controller;
  bool hasFav = false;
  int? isFav = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setCurrentUserData();
      setCurrentPasswordData();
    });
    tag_cotroller = TextEditingController();
    url_cotroller = TextEditingController();
    login_cotroller = TextEditingController();
    password_cotroller = TextEditingController();
    id_controller = TextEditingController();
    print("get new user data");
  }

  @override
  void dispose() {
    tag_cotroller.dispose();
    url_cotroller.dispose();
    login_cotroller.dispose();
    password_cotroller.dispose();
    id_controller.dispose();
    super.dispose();
  }

  void setPasswordListByCondition() async {
    PasswordSearchResult result =
        await UserManager.getPasswordDataByUserIDAndCondition(
            userID: widget.userID,
            id: id_controller.text,
            isFav: hasFav ? isFav : null,
            login: login_cotroller.text,
            password: password_cotroller.text,
            tag: tag_cotroller.text,
            url: url_cotroller.text);
    if (result.passwordDataList!.isNotEmpty) {
      setState(() {
        passwordDataList = result.passwordDataList!;
        Utilities.showNormalSnackBar(
            context, "已找到相似的搜尋結果", const Duration(seconds: 2));
      });
    } else {
      setState(() {
        passwordDataList = [];
        Utilities.showNormalSnackBar(
            context, "尚未在密碼庫找到相關資料", const Duration(seconds: 2));
      });
    }
  }

  void setCurrentUserData() async {
    UserData _userdata = await UserDAO.getUserDataByUserID(widget.userID);
    setState(() {
      userData = _userdata;
      print("post new userData");
    });
  }

  void setCurrentPasswordData() async {
    List<PasswordData> _passwordDataList =
        await PasswordDAO.getPasswordDataByUserID(widget.userID);
    setState(() {
      passwordDataList = _passwordDataList;
      print("post new passwordData");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingAddPasswordButton(),
      key: _scaffoldKey,
      drawer: navDrawerContent(context),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: homeAppBar(context),
      ),
      body: SingleChildScrollView(
          child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Text(
              "密碼清單",
              style: TextStyle(fontSize: 30),
            ),
            searchBar(),
            passwordListViewMaker()
          ],
        ),
      )),
    );
  }

  Widget searchBar() {
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.all(15),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              color: StyleColor.soFkLightGrey,
              border: Border.all(color: StyleColor.black, width: 1.5)),
          child: Column(children: [
            const Text("標籤"),
            SizedBox(
              height: 30,
              width: 320,
              child: TextFormField(
                controller: tag_cotroller,
              ),
            ),
            const Text("網址"),
            SizedBox(
              height: 30,
              width: 320,
              child: TextFormField(
                controller: url_cotroller,
              ),
            ),
            const Text("登入帳號"),
            SizedBox(
              height: 30,
              width: 320,
              child: TextFormField(
                controller: login_cotroller,
              ),
            ),
            const Text("密碼"),
            SizedBox(
              height: 30,
              width: 320,
              child: TextFormField(
                controller: password_cotroller,
              ),
            ),
            const Text("密碼ID"),
            SizedBox(
              height: 30,
              width: 320,
              child: TextFormField(
                controller: id_controller,
              ),
            ),
            Row(
              children: [
                Expanded(
                    child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text("啟用我的最愛"),
                        value: (hasFav),
                        onChanged: (value) {
                          setState(() {
                            hasFav = !hasFav;
                          });
                        })),
                Expanded(
                    child: CheckboxListTile(
                        enabled: hasFav,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text("我的最愛"),
                        value: (isFav == 1 ? true : false),
                        onChanged: (value) {
                          setState(() {
                            isFav = isFav == 0 ? 1 : 0;
                          });
                        })),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: StyleColor.lightgrey),
                    onPressed: () {
                      setPasswordListByCondition();
                    },
                    child: const Text(
                      "搜尋",
                      style: TextStyle(color: StyleColor.white),
                    )),
                TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: StyleColor.lightgrey),
                    onPressed: () {
                      setState(
                        () {
                          tag_cotroller.text = "";
                          url_cotroller.text = "";
                          login_cotroller.text = "";
                          password_cotroller.text = "";
                          id_controller.text = "";
                          hasFav = false;
                          isFav = 1;
                          Utilities.showNormalSnackBar(
                              context, "已清除搜尋的設定", const Duration(seconds: 2));
                        },
                      );
                    },
                    child: const Text(
                      "清除設定",
                      style: TextStyle(color: StyleColor.white),
                    )),
                TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: StyleColor.lightgrey),
                    onPressed: () {
                      setCurrentPasswordData();
                      Utilities.showNormalSnackBar(
                          context, "已取消搜尋", const Duration(seconds: 2));
                    },
                    child: const Text(
                      "取消搜尋",
                      style: TextStyle(color: StyleColor.white),
                    )),
              ],
            )
          ]),
        ),
      );
    });
  }

  Widget passwordListViewMaker() {
    return SizedBox(
      width: 350,
      child: ListView.builder(
          primary: false,
          shrinkWrap: true,
          itemCount: passwordDataList.length,
          itemBuilder: (context, index) {
            return dataCard(passwordDataList[index]);
          }),
    );
  }

  Widget dataCard(PasswordData passwordData) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 320,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            border: Border.all(color: StyleColor.black, width: 2.0),
            borderRadius: BorderRadius.circular(45)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 130,
                    child: Text(
                      "標籤",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Text(passwordData.tag, style: const TextStyle(fontSize: 25)),
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 130,
                    child: Text(
                      "URL",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Text(passwordData.url, style: const TextStyle(fontSize: 25)),
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 130,
                    child: Text(
                      "登入帳號",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Text(passwordData.login,
                      style: const TextStyle(fontSize: 25)),
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 130,
                    child: Text(
                      "密碼",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Text(passwordData.password,
                      style: const TextStyle(fontSize: 25)),
                ],
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 130,
                    child: Text(
                      "密碼ID",
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  Text(passwordData.id, style: const TextStyle(fontSize: 25)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          passwordData.isFav = passwordData.isFav == 1 ? 0 : 1;
                          PasswordDAO.updatePasswordDataByPasswordID(
                              passwordData);
                          Utilities.showNormalSnackBar(
                              context, "已更改", const Duration(seconds: 1));
                        });
                      },
                      icon: passwordData.isFav == 1
                          ? const Icon(
                              Icons.favorite,
                              color: StyleColor.red,
                            )
                          : const Icon(
                              Icons.favorite_border,
                              color: StyleColor.red,
                            )),
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: StyleColor.green,
                        shape: const CircleBorder()),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              EditPage(passwordData: passwordData)));
                    },
                    child: const Icon(
                      Icons.edit,
                      color: StyleColor.white,
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: StyleColor.red,
                        shape: const CircleBorder()),
                    onPressed: () {
                      PasswordDAO.deletePasswordByPasswordID(passwordData.id);
                      setCurrentPasswordData();
                    },
                    child: const Icon(
                      Icons.delete,
                      color: StyleColor.white,
                    ),
                  ),
                ],
              )
            ]),
      ),
    );
  }

  Widget homeAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: StyleColor.black,
      centerTitle: true,
      title: const Text(
        "主畫面",
        style: TextStyle(color: StyleColor.white),
      ),
      // leading: IconButton(
      //   icon: const Icon(
      //     Icons.menu,
      //     color: StyleColor.white,
      //   ),
      //   onPressed: () {
      //     _scaffoldKey.currentState?.closeDrawer();
      //   },
      // ),
    );
  }

  Widget navDrawerContent(context) {
    return Drawer(
      width: 280,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    _scaffoldKey.currentState?.closeDrawer();
                  },
                  icon: const Icon(Icons.close)),
              Image.asset(
                "assets/icon.png",
                width: 20,
                height: 20,
              )
            ],
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text("主畫面"),
          onTap: () {
            _scaffoldKey.currentState?.closeDrawer();
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("帳號設定"),
          onTap: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => UserPage(
                      userData: userData,
                    )));
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("匯出密碼庫"),
          onTap: () {},
        ),
        logoutButton()
      ]),
    );
  }

  Widget logoutButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 40,
        width: double.infinity,
        child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(45)),
                backgroundColor: StyleColor.white,
                side: const BorderSide(color: StyleColor.red, width: 1.5)),
            onPressed: () async {
              await SharedPref.cleanLoggedUserID();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              }
            },
            child: const Text(
              "登出",
              style: TextStyle(color: StyleColor.red, fontSize: 20),
            )),
      ),
    );
  }

  Widget floatingAddPasswordButton() {
    return FloatingActionButton(
      backgroundColor: StyleColor.black,
      onPressed: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddPage(userID: userData.id)));
      },
      child: const Icon(
        Icons.add,
        size: 30,
      ),
    );
  }
}
