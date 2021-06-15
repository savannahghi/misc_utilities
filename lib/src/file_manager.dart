import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:misc_utilities/src/file_manager_logic.dart';
import 'package:misc_utilities/src/string_constant.dart';
import 'package:misc_utilities/src/widget_keys.dart';

import 'package:shared_themes/constants.dart';
import 'package:shared_themes/spaces.dart';
import 'package:shared_themes/text_themes.dart';

typedef OnFileChanged = void Function(dynamic value);

typedef UploadReturnId = Future<String> Function({
  required Map<String, dynamic> fileData,
  required BuildContext context,
});

/// renders a widget that can be used to
/// select files from storage or take photo with the camera
/// [onChanged] is more like the [TextField] onChanged, basically is a
/// [Function] that takes a value which in this case is an [uploadId]
/// [fileTitle] indicates the file type you want, ie `Military ID`
/// [allowedExtensions] is an optional list of strings containing file extensions
/// [uploadFileAndReturnIdFunction] is a [Function] of type [UploadReturnId] that uploads a file's
/// data and returns an [uploadId]
/// [snackBarTypes] is a list of the types of snack bars available

class SILFileManager extends StatefulWidget {
  const SILFileManager({
    Key? key,
    required this.onChanged,
    required this.fileTitle,
    required this.uploadAndReturnIdFunction,
    required this.silLoader,
    this.invalidFile = false,
  }) : super(key: key);

  final bool invalidFile;
  final String fileTitle;
  final OnFileChanged onChanged;
  final Widget silLoader;
  final UploadReturnId uploadAndReturnIdFunction;

  @override
  _SILFileManagerState createState() => _SILFileManagerState();
}

class _SILFileManagerState extends State<SILFileManager> {
  File? selectedFile;
  bool uploading = false;

  void toggleUpload() {
    setState(() {
      uploading = !uploading;
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
                            if (selectedFile == null) ...<Widget>[
                              /// Select from gallery
                              GestureDetector(
                                key: galleryImageKey,
                                onTap: () async {
                                  await FileManagerLogic.selectFile(
                                    context: context,
                                    uploadAndReturnIdFunction:
                                        widget.uploadAndReturnIdFunction,
                                    toggleUpload: toggleUpload,
                                    fileTitle: widget.fileTitle,
                                    updateUIFunc: (File file, String uploadId) {
                                      setState(() {
                                        selectedFile = file;
                                        widget.onChanged(uploadId);
                                      });
                                    },
                                  );
                                },
                                child: Column(
                                  children: <Widget>[
                                    SvgPicture.asset(
                                      'assets/images/folder.svg',
                                      width: 40,
                                      height: 40,
                                    ),
                                    verySmallVerticalSizedBox,
                                    Text(UserFeedBackTexts.controlLabels[0])
                                  ],
                                ),
                              ),

                              /// -----take photo
                            ],

                            /// -----reset file set to none
                            if (selectedFile != null) ...<Widget>[
                              SizedBox(
                                height: 90,
                                child: Image.file(selectedFile!),
                              ),
                              GestureDetector(
                                key: closeSelectedFile,
                                onTap: () {
                                  setState(() {
                                    selectedFile = null;
                                  });
                                  widget.onChanged(selectedFile);
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
                            selectAPhotoOfMessage(widget.fileTitle),
                            textAlign: TextAlign.center,
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
        if (widget.invalidFile) ...<Widget>[
          smallVerticalSizedBox,
          Text(
            'This is required *',
            style: TextThemes.normalSize14Text(Colors.red),
          )
        ],
      ],
    );
  }
}
