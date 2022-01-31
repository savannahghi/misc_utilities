import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:misc_utilities/constants.dart';
import 'package:misc_utilities/src/misc.dart';
import 'package:misc_utilities/src/types.dart';
import 'package:misc_utilities/string_constant.dart';
import 'package:shared_themes/constants.dart';

class FileManagerLogic {
  /// Gets the file metadata that is to be consumed by the api
  ///
  /// This involves:
  ///  - The image base64 data, a [String]
  ///  - The content type; whether `PNG` or `JPG`
  ///  - The file name
  ///  - The title of the file
  ///  - The language; defaults to English(en)
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

  /// Converts the [file] size from [Bytes] to [Kilobytes]
  static Future<int> getFileSize(File file) async {
    final int bytes = file.lengthSync();
    return bytes ~/ 1024;
  }

  /// Selects a file from the gallery
  ///
  /// Takes a [BuildContext] that is used to show alert messages using the
  /// ` ScaffoldMessenger.of(context).showSnackBar()` method.
  ///
  /// The [UploadReturnId] is used to upload the file
  ///
  /// The [fileTitle] is the name of the upload to be used
  ///
  /// The [updateUIFunc] returns a [File] object and the [uploadId] so that
  /// the UI can be refreshed with the updated values after uploading the file
  static Future<void> selectFileFromGallery({
    required BuildContext context,
    required UploadReturnId uploadAndReturnIdFunction,
    required Function toggleUpload,
    required String fileTitle,
    required void Function(File file, String uploadId) updateUIFunc,
  }) async {
    PickedFile? pickedFile;

    try {
      pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackbar(content: UserFeedBackTexts.selectFileError));
      return;
    }

    if (pickedFile != null) {
      /// checks that [result.files] has one file and returns that file
      final File selectedFile = File(pickedFile.path);
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
      // The user canceled the picker so we alert them
      ScaffoldMessenger.of(context)
          .showSnackBar(snackbar(content: UserFeedBackTexts.noFileSelected));
    }
  }
}
