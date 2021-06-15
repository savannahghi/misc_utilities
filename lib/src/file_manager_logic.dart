import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:misc_utilities/constants.dart';
import 'package:misc_utilities/file_manager.dart';
import 'package:misc_utilities/string_constant.dart';
import 'package:misc_utilities/src/misc.dart';

import 'package:shared_themes/constants.dart';

class FileManagerLogic {
  /// get the file metadata that is to be consumed by the api
  static Map<String, dynamic> getFileData(
      {required File file, required String fileTitle}) {
    return <String, dynamic>{
      'base64data': base64Encode(file.readAsBytesSync()),
      'contentType': file.path.split('/').last.split('.').last.toUpperCase(),
      'filename': file.path.split('/').last,
      'title': fileTitle,
      'language': 'en',
    };
  }

  /// Converts the file size from bytes to Kilobytes
  static Future<int> getFileSize(File file) async {
    final int bytes = file.lengthSync();
    return bytes ~/ 1024;
  }

  /// select file from the gallery
  static Future<void> selectFile({
    required BuildContext context,
    required UploadReturnId uploadAndReturnIdFunction,
    required Function toggleUpload,
    required String fileTitle,
    required void Function(File file, String uploadId) updateUIFunc,
  }) async {
    PickedFile? result;

    try {
      result = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackbar(content: UserFeedBackTexts.selectFileError));
      return;
    }

    if (result != null) {
      /// checks that [result.files] has one file and returns that file
      final File selectedFile = File(result.path);
      final int selectedFileSizeInKb = await getFileSize(selectedFile);

      if (selectedFileSizeInKb > fileUploadSizeThresholdInKb) {
        // User canceled the picker
        ScaffoldMessenger.of(context)
            .showSnackBar(snackbar(content: tooLargeImageError));
        return;
      }

      toggleUpload();

      /// uploads the file and returns an [uploadID]
      final String uploadId = await uploadAndReturnIdFunction(
          fileData: getFileData(file: selectedFile, fileTitle: fileTitle),
          context: context);
      toggleUpload();
      if (uploadId == 'err') {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackbar(content: UserFeedBackTexts.uploadFileFail));
        return;
      }
      updateUIFunc(selectedFile, uploadId);
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context)
          .showSnackBar(snackbar(content: UserFeedBackTexts.noFileSelected));
    }
  }
}
