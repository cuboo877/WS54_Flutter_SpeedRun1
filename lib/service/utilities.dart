import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ws54_flutter_prac2/constant/style_guide.dart';

class Utilities {
  static randomID() {
    final random = Random();
    String result = "";
    for (int i = 0; i < 10; i++) {
      result += random.nextInt(9).toString();
    }
    return result;
  }

  static String randomPassword(bool hasLowerCase, bool hasUpperCase,
      bool hasSymbol, bool hasNumber, int length, String? customChars) {
    StringBuffer buffer = StringBuffer();
    StringBuffer resultBuffer = StringBuffer();
    int customCharsLength = 0;
    if (customChars == null) {
      customCharsLength = 0;
    } else {
      customCharsLength = customChars.length;
    }
    if (hasLowerCase) {
      buffer.write("abcdefghijklmnopqrstuvwxyz");
    }
    if (hasUpperCase) {
      buffer.write("ABCDEFGHIJKLMNOPQRSTUVWXYZ");
    }
    if (hasSymbol) {
      buffer.write("!@#_?|+=-()*&^%");
    }
    if (hasNumber) {
      buffer.write("0123456789");
    }
    Random random = Random();
    for (int i = 0; i < (length - customCharsLength); i++) {
      resultBuffer.write(buffer.toString()[random.nextInt(buffer.length)]);
    }
    String resultBufferString = resultBuffer.toString();
    int insertIndex = random.nextInt(resultBufferString.length);
    resultBufferString =
        "${resultBufferString.substring(0, insertIndex)}$customChars${resultBufferString.substring(insertIndex, resultBufferString.length)}";
    return resultBufferString;
  }

  static showNormalSnackBar(
      BuildContext context, String title, Duration duration) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: StyleColor.black,
        duration: duration,
        content: Text(
          title,
          style: const TextStyle(color: StyleColor.white, fontSize: 20),
        )));
  }

  static showLoadingWindow(BuildContext context, String title, String content) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Row(children: [
              const CircularProgressIndicator(),
              const SizedBox(
                width: 20,
              ),
              Text(content),
            ]),
          );
        });
  }
}
