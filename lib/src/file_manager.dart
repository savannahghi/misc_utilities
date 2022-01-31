import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:misc_utilities/src/file_manager_logic.dart';
import 'package:misc_utilities/src/loading_wrapper.dart';
import 'package:misc_utilities/src/string_constant.dart';
import 'package:misc_utilities/src/types.dart';
import 'package:misc_utilities/src/widget_keys.dart';
import 'package:shared_themes/constants.dart';
import 'package:shared_themes/spaces.dart';
import 'package:shared_themes/text_themes.dart';

/// A Widget used to select and upload files from the gallery or the camera
///
/// [onChanged] is more like the [TextField] onChanged, basically is a
/// [Function] that takes a value which in this case is an [uploadId]
///
/// [fileTitle] indicates the file type you want, ie `Military ID`
///
/// [allowedExtensions] is an optional list of strings containing file
///  extensions
///
/// [uploadFileAndReturnIdFunction] is a [Function] of type [UploadReturnId]
/// that uploads a file's data and returns an [uploadId]
class FileManager extends StatefulWidget {
  const FileManager({
    required this.onChanged,
    required this.fileTitle,
    required this.uploadAndReturnIdFunction,
    required this.platformLoader,
    this.isRequired = false,
    this.galleryImageKey,
    this.dismissIconKey,
  });

  /// The Key for the dismiss icon
  final Key? dismissIconKey;

  /// The title of the file to be used after upload
  final String fileTitle;

  /// The key to be used for the gallery image selection
  final Key? galleryImageKey;

  /// Whether this file upload is required
  final bool isRequired;

  /// Will be called when the file has been uploaded and an upload ID is
  /// available
  final OnFileChanged onChanged;

  /// The loading indicator to be used when the upload is in progress
  final Widget platformLoader;

  /// The function to upload the file and return the upload ID
  ///
  /// Takes in a Map of the image data, and a [BuildContext] that is used
  /// to notify the user once the upload is successful
  final UploadReturnId uploadAndReturnIdFunction;

  @override
  _FileManagerState createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  File? selectedFile;
  bool isUploadingFile = false;

  void toggleUploadStatus() {
    setState(() {
      isUploadingFile = !isUploadingFile;
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
            child: isUploadingFile
                ? LoadingWrapper(loader: widget.platformLoader)
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
                                key: widget.galleryImageKey ?? galleryImageKey,
                                onTap: () async {
                                  await FileManagerLogic.selectFileFromGallery(
                                    context: context,
                                    uploadAndReturnIdFunction:
                                        widget.uploadAndReturnIdFunction,
                                    toggleUpload: toggleUploadStatus,
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
                            ],
                            if (selectedFile != null) ...<Widget>[
                              // The selected image
                              SizedBox(
                                height: 90,
                                child: Image.file(selectedFile!),
                              ),

                              /// Remove the uploaded file
                              GestureDetector(
                                key: widget.dismissIconKey ?? closeSelectedFile,
                                onTap: () {
                                  setState(() {
                                    selectedFile = null;
                                  });
                                  widget.onChanged(null);
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
        if (widget.isRequired) ...<Widget>[
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
