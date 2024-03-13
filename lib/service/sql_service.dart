import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:ws54_flutter_prac2/service/sharedPref.dart';

// ignore: camel_case_types
class UserDAO {
  static Database? userDB;

  static Future<Database> _initUserDatabase() async {
    userDB = await openDatabase(join(await getDatabasesPath(), "ws2.db"),
        onCreate: (db, version) async {
      await db.execute(
          'CREATE TABLE users (id TEXT PRIMARY KEY, username TEXT, account TEXT, password TEXT, birthday TEXT)');
      await db.execute(
          'CREATE TABLE passwords (id TEXT PRIMARY KEY, userID TEXT, tag TEXT, url TEXT, login TEXT, password TEXT, isFav INTEGER, FOREIGN KEY (userID) REFERENCES users (id))');
    }, version: 1);
    return userDB!;
  }

  static Future<Database> _getDBConnect() async {
    if (userDB != null) {
      return userDB!;
    } else {
      return await _initUserDatabase();
    }
  }

  static Future<List<UserData>> getAllUserData() async {
    final Database userDB = await _getDBConnect();
    final List<Map<String, dynamic>> maps = await userDB.query("users");
    return List.generate(maps.length, (index) {
      return UserData(
          id: maps[index]["id"],
          username: maps[index]["username"],
          account: maps[index]["account"],
          password: maps[index]["password"],
          birthday: maps[index]["birthday"]);
    });
  }

  static Future<UserData> getUserDataByUserID(String userID) async {
    final Database userDB = await _getDBConnect();
    final maps =
        await userDB.query("users", where: "id = ?", whereArgs: [userID]);
    final Map<String, dynamic> ud = maps.first;
    return UserData(
        id: ud["id"],
        username: ud["username"],
        account: ud["account"],
        password: ud["password"],
        birthday: ud["birthday"]);
  }

  static getLoginUserDataByAccountAndPassword(
      String account, String password) async {
    final Database userDB = await _getDBConnect();
    final maps = await userDB.query("users",
        where: "account = ? AND password = ?", whereArgs: [account, password]);
    final Map<String, dynamic> ud = maps.first;
    return UserData(
        id: ud["id"],
        username: ud["username"],
        account: ud["account"],
        password: ud["password"],
        birthday: ud["birthday"]);
  }

  static updateUserDataByUserID(UserData ud) async {
    final Database userDB = await _getDBConnect();
    final userID = ud.id;
    await userDB.update("users", ud.toJson(),
        where: "id = ?",
        whereArgs: [userID],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static deleteUserDataByUserID(String userID) async {
    final Database userDB = await _getDBConnect();
    await userDB.delete("users", where: "id = ?", whereArgs: [userID]);
  }

  static void addUserData(UserData ud) async {
    final Database userDB = await _getDBConnect();
    await userDB.insert("users", ud.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static getUserDataByAccount(String account) async {
    final Database userDB = await _getDBConnect();
    final maps =
        await userDB.query("users", where: "account = ?", whereArgs: [account]);
    final Map<String, dynamic> ud = maps.first;
    return UserData(
        id: ud["id"],
        username: ud["username"],
        account: ud["account"],
        password: ud["password"],
        birthday: ud["birthday"]);
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class PasswordDAO {
  static Future<List<PasswordData>> getPasswordDataByUserID(
      String userID) async {
    final Database passwordDB = await UserDAO._getDBConnect();
    List<Map<String, dynamic>> maps = await passwordDB
        .query("passwords", where: "userID = ?", whereArgs: [userID]);
    return List.generate(maps.length, (index) {
      return PasswordData(
          id: maps[index]["id"],
          userID: maps[index]["userID"],
          tag: maps[index]["tag"],
          url: maps[index]["url"],
          login: maps[index]["login"],
          password: maps[index]["password"],
          isFav: maps[index]["isFav"]);
    });
  }

  static void deletePasswordByPasswordID(String passwordID) async {
    final Database passwordDB = await UserDAO._getDBConnect();
    passwordDB.delete("passwords", where: "id = ?", whereArgs: [passwordID]);
  }

  static void cleanPasswordDataTAbleByUserID(String userID) async {
    final Database passwordDB = await UserDAO._getDBConnect();
    passwordDB.delete("passwords", where: "userId = ?", whereArgs: [userID]);
  }

  static void updatePasswordDataByPasswordID(PasswordData passwordData) async {
    final Database passwordDB = await UserDAO._getDBConnect();
    await passwordDB.update("passwords", passwordData.toJson(),
        where: "id = ?",
        whereArgs: [passwordData.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static void addPasswordData(String userID, PasswordData passwordData) async {
    final Database passwordDB = await UserDAO._getDBConnect();
    await passwordDB.insert("passwords", passwordData.toJson());
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
class UserData {
  UserData(
      {required this.id,
      required this.username,
      required this.account,
      required this.password,
      required this.birthday});
  final String id;
  late String username;
  late String account;
  late String password;
  late String birthday;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "username": username,
      "account": account,
      "password": password,
      "birthday": birthday
    };
  }
}

class PasswordData {
  PasswordData(
      {required this.id,
      required this.userID,
      required this.tag,
      required this.url,
      required this.login,
      required this.password,
      required this.isFav});
  final String id;
  final String userID;
  late String tag;
  late String url;
  late String login;
  late String password;
  late int isFav;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userID": userID,
      "tag": tag,
      "url": url,
      "login": login,
      "password": password,
      "isFav": isFav
    };
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

class UserManager {
  static void initAllTable() async {
    await UserDAO._initUserDatabase();
    print("init all table");
  }

  static Future<void> logoutUserByUserID(String userID) async {
    await SharedPref.cleanLoggedUserID();
  }

  static Future<LoginResult> loginReturnResult(
      String account, String password) async {
    try {
      final ud =
          await UserDAO.getLoginUserDataByAccountAndPassword(account, password);
      await SharedPref.setLoggedUserID(ud.id);
      return LoginResult(success: true, userData: ud);
    } catch (e) {
      return LoginResult(success: false, message: e.toString());
    }
  }

  static Future<RegisterResult> registerReturnResult(UserData userData) async {
    try {
      UserDAO.addUserData(userData);
      UserData ud = await UserDAO.getUserDataByUserID(userData.id);
      await SharedPref.setLoggedUserID(ud.id);
      return RegisterResult(success: true, userData: ud);
    } catch (e) {
      return RegisterResult(success: false, message: e.toString());
    }
  }

  static Future<PasswordSearchResult> getPasswordDataByUserIDAndCondition(
      {required String userID,
      String? id,
      String? tag,
      String? url,
      String? login,
      String? password,
      int? isFav}) async {
    try {
      final passwordDB = await UserDAO._getDBConnect();
      String whereCondition = "userID = ?";
      List<dynamic> whereArgs = [userID];

      if (id != null && id.isNotEmpty) {
        whereCondition += "AND id LIKE = ?";
        whereArgs.add("%$id%");
      }
      if (tag != null && tag.isNotEmpty) {
        whereCondition += "AND tag LIKE = ?";
        whereArgs.add("%$tag%");
      }
      if (url != null && url.isNotEmpty) {
        whereCondition += "AND url LIKE = ?";
        whereArgs.add("%$url%");
      }
      if (login != null && login.isNotEmpty) {
        whereCondition += "AND login LIKE = ?";
        whereArgs.add("%$login%");
      }
      if (password != null && password.isNotEmpty) {
        whereCondition += "AND password LIKE = ?";
        whereArgs.add("%$password%");
      }
      if (isFav != null) {
        whereCondition += "AND isFav = ?";
        whereArgs.add(isFav);
      }
      List<Map<String, dynamic>> maps = await passwordDB.query("passwords",
          where: whereCondition, whereArgs: whereArgs);
      List<PasswordData> result = List.generate(maps.length, (index) {
        return PasswordData(
            id: maps[index]["id"],
            userID: maps[index]["userID"],
            tag: maps[index]["tag"],
            url: maps[index]["url"],
            login: maps[index]["login"],
            password: maps[index]["password"],
            isFav: maps[index]["isFav"]);
      });
      return PasswordSearchResult(success: true, passwordDataList: result);
    } catch (e) {
      return PasswordSearchResult(success: false, message: "找不到與其相似的密碼!");
    }
  }

  static Future<bool> hasAccountBeenRegistered(String account, String password,
      bool isAccountValid, bool isPasswordValid, bool isConfirmValid) async {
    try {
      await UserDAO.getUserDataByAccount(account);
      return true;
    } catch (e) {
      return false;
    }
  }
}

class LoginResult {
  LoginResult({this.userData, this.message = "", required this.success});
  final UserData? userData;
  final String message;
  final bool success;
}

class RegisterResult {
  RegisterResult({this.userData, this.message = "", required this.success});
  final UserData? userData;
  final String message;
  final bool success;
}

class PasswordSearchResult {
  PasswordSearchResult(
      {this.passwordDataList, this.message = "", required this.success});
  final List<PasswordData>? passwordDataList;
  final String message;
  final bool success;
}
