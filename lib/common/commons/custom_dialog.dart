import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.onConfirm,
    this.cancelText = 'Cancelar',
    this.onCancel,
  });

  final String title;
  final Widget content;
  final String? confirmText;
  final VoidCallback? onConfirm;
  final String cancelText;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      content: content,
      actions: <Widget>[
        TextButton(
          onPressed: onConfirm,
          child: Text(
            confirmText ?? '',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(cancelText),
        ),
      ],
    );
  }
}
