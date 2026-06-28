import 'dart:async';
import 'package:flutter/material.dart';

class CountdownDialog {
  static Future<void> show(
    BuildContext context, {
    int startFrom = 3,
    VoidCallback? onFinished,
  }) async {
    int countDown = startFrom;
    late StateSetter dialogState;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            backgroundColor: Colors.white.withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: StatefulBuilder(
              builder: (context, setState) {
                dialogState = setState;
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      countDown.toString(),
                      style: const TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (countDown == 1) {
        timer.cancel();
        Navigator.of(context).pop();
        if (onFinished != null) {
          onFinished();
        }
      } else {
        countDown--;
        dialogState(() {});
      }
    });
  }
}
