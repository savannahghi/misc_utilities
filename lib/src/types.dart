import 'package:flutter/material.dart';

typedef UploadReturnId = Future<String> Function({
  required Map<String, dynamic> fileData,
  required BuildContext context,
});

typedef OnFileChanged = void Function(String? value);
