import 'package:flutter/material.dart';
import 'package:login_page/consts/consts.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onTryAgain;
  final VoidCallback onSubmit;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onTryAgain = _defaultAction,
    this.onSubmit = _defaultAction,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback onTryAgain = _defaultAction,
    VoidCallback onSubmit = _defaultAction,
  }) {
    showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onTryAgain: onTryAgain,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18,
          ),
        ),
      ),
      content: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Text(message),
      ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onTryAgain();
          },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: MYmaincolor, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "Try Again",
            style: TextStyle(color: MYmaincolor),
          ),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onSubmit();
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: MYmaincolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "Submit a Report",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// Default function that does nothing
void _defaultAction() {}
