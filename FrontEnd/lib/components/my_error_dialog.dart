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
        width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Text(
          message,
          textAlign: TextAlign.justify,
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton(
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
            ),
            const SizedBox(width: 10), // Space between buttons
            Expanded(
              child: OutlinedButton(
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
      insetPadding: const EdgeInsets.symmetric(horizontal: 15),
    );
  }
}

// Default function that does nothing
void _defaultAction() {}
