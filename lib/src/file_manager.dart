import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:sil_misc/src/misc.dart';

import 'package:sil_themes/constants.dart';
import 'package:sil_themes/spaces.dart';
import 'package:sil_themes/text_themes.dart';

typedef OnFileChanged = void Function(dynamic value);

typedef GetUploadId = Future<String> Function({
  required Map<String, dynamic> fileData,
  required BuildContext context,
});

/// renders a widget that can be used to
/// select files from storage or take photo with the camera
/// [onChanged] is more like the [TextField] onChanged, basically is a
/// [Function] that takes a value which in this case is an [uploadId]
/// [name] indicates the file type you want, ie `Military ID`
/// [allowedExtensions] is an optional list of strings containing file extensions
/// [getUploadId] is a [Function] of type [GetUploadId] that uploads a file's
/// data and returns an [uploadId]
/// [snackBarTypes] is a list of the types of snackbars available

class SILFileManager extends StatefulWidget {
  const SILFileManager({
    Key? key,
    required this.onChanged,
    required this.name,
    required this.getUploadId,
    required this.silLoader,
    this.allowedExtensions = const <String>['jpg', 'png'],
    this.invalidF = false,
  }) : super(key: key);

  final OnFileChanged onChanged;
  final bool invalidF;
  final String name;
  final List<String> allowedExtensions;
  final GetUploadId getUploadId;
  final Widget silLoader;

  @override
  _SILFileManagerState createState() => _SILFileManagerState();
}

class _SILFileManagerState extends State<SILFileManager> {
  File? file;
  bool uploading = false;

  void toggleUpload() {
    setState(() {
      uploading = !uploading;
    });
  }

  /// get the file metadata that is to be consumed by the api
  Map<String, dynamic> getFileData(File file) {
    return <String, dynamic>{
      'base64data': base64Encode(file.readAsBytesSync()),
      'contentType': file.path.split('/').last.split('.').last.toUpperCase(),
      'filename': file.path.split('/').last,
      'title': widget.name,
      'language': 'en',
    };
  }

  /// select file from storage
  Future<void> selectFile() async {
    PickedFile? result;
    try {
      /// Retrieves the file(s) from the underlying platform
      ///
      result = await ImagePicker()
          .getImage(source: ImageSource.gallery, imageQuality: 50);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackbar(content: UserFeedBackTexts.selectFileError));
    }
    if (result != null) {
      /// checks that [result.files] has one file and returns that file
      final File selectedFile = File(result.path);
      toggleUpload();

      /// uploads the file and returns an [uploadID]
      final String uploadId = await widget.getUploadId(
          fileData: getFileData(selectedFile), context: context);
      toggleUpload();
      if (uploadId == 'err') {
        ScaffoldMessenger.of(context)
            .showSnackBar(snackbar(content: UserFeedBackTexts.uploadFileFail));
        return;
      }
      setState(() {
        file = selectedFile;
        widget.onChanged(uploadId);
      });
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context)
          .showSnackBar(snackbar(content: UserFeedBackTexts.noFileSelected));
    }
  }

  static Future<File?> compressAndGetFile(File file) async {
    final String filePath = file.absolute.path;

    // Create output file path
    final int lastIndex = filePath.lastIndexOf(RegExp('.jp'));
    final String splitFilePath = filePath.substring(0, lastIndex);
    final String outPath =
        '${splitFilePath}_out${filePath.substring(lastIndex)}';
    final File? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 30,
    );
    return result;
  }

  /// take photo with camera
  Future<void> takePhoto() async {
    /// shows a dialogue that pushes a [MaterialPageRoute]
    final PickedFile? image = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);
    onFile(File(image!.path));
  }

  Future<void> onFile(File fileData) async {
    final File compressedFile = (await compressAndGetFile(fileData))!;
    final File image = File(compressedFile.path);

    final File selectedFile = image;
    toggleUpload();

    /// uploads the file and returns an [uploadID
    final String uploadId = await widget.getUploadId(
        fileData: getFileData(selectedFile), context: context);
    toggleUpload();
    if (uploadId == 'err') {
      ScaffoldMessenger.of(context)
          .showSnackBar(snackbar(content: UserFeedBackTexts.uploadFileFail));

      return;
    }
    setState(() {
      file = selectedFile;
      widget.onChanged(uploadId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DottedBorder(
          color: Theme.of(context).primaryColor.withOpacity(0.8),
          dashPattern: const <double>[14, 6],
          borderType: BorderType.RRect,
          radius: const Radius.circular(10),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
            ),
            child: uploading
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: <Widget>[
                          widget.silLoader,
                          smallVerticalSizedBox,
                          const Text(UserFeedBackTexts.savingFile)
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            if (file == null) ...<Widget>[
                              /// -----select photo
                              _buildGestureDetector(
                                context: context,
                                iconPath: 'assets/images/folder.svg',
                                text: UserFeedBackTexts.controlLabels[0],
                                onTap: selectFile,
                              ),

                              /// -----take photo
                              _buildGestureDetector(
                                context: context,
                                iconPath: 'assets/images/camera.svg',
                                text: UserFeedBackTexts.controlLabels[1],
                                onTap: takePhoto,
                              ),
                            ],

                            /// -----reset file set to none
                            if (file != null) ...<Widget>[
                              SizedBox(
                                height: 90,
                                child: Image.file(file!),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    file = null;
                                  });
                                  widget.onChanged(file);
                                },
                                child: Column(
                                  children: <Widget>[
                                    const Icon(MdiIcons.closeCircle),
                                    Text(UserFeedBackTexts.controlLabels[2]),
                                  ],
                                ),
                              )
                            ]
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        color: Colors.blueAccent.withOpacity(0.05),
                        child: Center(
                          child: Text(
                            UserFeedBackTexts.selectOrTakeMessage(widget.name),
                            style: TextThemes.heavySize14Text(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (widget.invalidF) ...<Widget>[
          smallVerticalSizedBox,
          Text(
            'This is required *',
            style: TextThemes.normalSize14Text(Colors.red),
          )
        ],
      ],
    );
  }

  /// builds a tappable widget to select file or take photo
  Widget _buildGestureDetector({
    BuildContext? context,
    Function? onTap,
    required String iconPath,
    required String text,
  }) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Column(
        children: <Widget>[
          SvgPicture.asset(
            iconPath,
            width: 40,
            height: 40,
          ),
          verySmallVerticalSizedBox,
          Text(text)
        ],
      ),
    );
  }
}
