import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sil_themes/constants.dart';
import 'package:sil_themes/spaces.dart';
import 'package:sil_themes/text_themes.dart';

typedef FileOnchanged = void Function(dynamic value);

typedef GetUploadId = Future<String> Function({
  @required Map<String, dynamic> fileData,
  @required BuildContext context,
});

/// renders a widget that can be used to
/// select files from storage or take photo with the camera
/// [onChanged] is more like the [TextField] onChanged, basically is a
/// [Function] that takes a value which in this case is an [uploadId]
/// [name] indicates the file type you want, ie `Military ID`
/// [allowedExtensions] is an optional list of strings conatining file extensions
/// [getUploadId] is a [Function] of type [GetUploadId] that uploads a file's
/// data and returns an [uploadId]

class BWFileManager extends StatefulWidget {
  final FileOnchanged onChanged;
  final bool invalidF;
  final String name;
  final List<String> allowedExtensions;
  final GetUploadId getUploadId;
  final Widget silLoader;
  final Function showAlertSnackBar;

  const BWFileManager({
    Key key,
    @required this.onChanged,
    @required this.name,
    @required this.getUploadId,
    @required this.silLoader,
    @required this.showAlertSnackBar,
    this.allowedExtensions = const <String>['jpg', 'png'],
    this.invalidF = false,
  }) : super(key: key);
  @override
  _BWFileManagerState createState() => _BWFileManagerState();
}

class _BWFileManagerState extends State<BWFileManager> {
  File file;

  CameraController controller;
  Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras;

  bool uploading = false;

  /// get a list of available cameras (mainly its the back and front cameras)
  void getCameras() async {
    cameras = await availableCameras();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    await getCameras();

    /// get the first camera which happens to be the back camera with [ResolutionPreset] set as [medium]
    controller = CameraController(cameras[0], ResolutionPreset.medium);

    /// Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = controller.initialize();
    super.didChangeDependencies();
  }

  void toggleUpload() {
    setState(() {
      uploading = !uploading;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
    FilePickerResult result;
    try {
      /// Retrieves the file(s) from the underlying platform
      ///
      /// Default [type] set to [FileType.any] with [allowMultiple] set to [false]
      /// The result is wrapped in a [FilePickerResult]
      result = await FilePicker.platform.pickFiles(
        allowedExtensions: widget.allowedExtensions,
        type: FileType.custom,
      );
    } catch (e) {
      widget.showAlertSnackBar(
          context, UserFeedBackTexts.selectFileError, Colors.red);
    }
    if (result != null) {
      /// checks that [result.files] has one file and returns that file
      File selectedFile = File(result.files.single.path);
      toggleUpload();

      /// uploads the file and returns an [uploadID]
      String uploadId = await widget.getUploadId(
          fileData: getFileData(selectedFile), context: context);
      toggleUpload();
      if (uploadId == 'err') {
        widget.showAlertSnackBar(
            context, UserFeedBackTexts.uploadFileFail, Colors.red);
        return;
      }
      setState(() {
        file = selectedFile;
        widget.onChanged(uploadId);
      });
    } else {
      // User canceled the picker
      widget.showAlertSnackBar(
          context, UserFeedBackTexts.noFileSelected, Colors.black);
    }
  }

  /// take photo with camera
  Future<void> takePhoto() async {
    /// shows a dialogue that pushes a [MaterialPageRoute] with [fullscreenDialog] set as true
    String result = await showCameraDialog(
      context,
      controller,
      _initializeControllerFuture,
      widget.silLoader,
    );
    if (result == null) {
      return;
    }
    if (result != 'cancelled') {
      File selectedFile = File(result);
      toggleUpload();

      /// uploads the file and returns an [uploadID
      String uploadId = await widget.getUploadId(
          fileData: getFileData(selectedFile), context: context);
      toggleUpload();
      if (uploadId == 'err') {
        widget.showAlertSnackBar(context, UserFeedBackTexts.uploadFileFail);
        return;
      }
      setState(() {
        file = selectedFile;
        widget.onChanged(uploadId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DottedBorder(
          color: Theme.of(context).primaryColor.withOpacity(0.8),
          strokeWidth: 1,
          dashPattern: <double>[14, 6],
          borderType: BorderType.RRect,
          radius: Radius.circular(10),
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
                          Text(UserFeedBackTexts.savingFile)
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
                              Container(
                                child: Image.file(file),
                                height: 90,
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
                                    Icon(MdiIcons.closeCircle),
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
                        padding: EdgeInsets.all(10),
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
    BuildContext context,
    Function onTap,
    String iconPath,
    String text,
  }) {
    return GestureDetector(
      onTap: onTap,
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

/// shows a screen to take a picture
/// pushes a [MaterialPageRoute] with [fullscreenDialog] set as true
/// displays a preview of the image
Future<String> showCameraDialog(
  BuildContext context,
  CameraController controller,
  Future<void> initializeControllerFuture,
  Widget silLoader,
) async {
  return await Navigator.of(context).push(MaterialPageRoute<String>(
    builder: (BuildContext context) {
      return Scaffold(
        body: FutureBuilder<void>(
          future: initializeControllerFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final Size size = MediaQuery.of(context).size;
              // If the Future is complete, display the preview.
              return Container(
                width: size.width,
                height: size.height,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      left: 0,
                      bottom: 0,
                      right: 0,
                      child: CameraPreview(controller),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        constraints: BoxConstraints(
                          maxWidth: 500,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            border: Border.all(color: Colors.white)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            color: Colors.white,
                          ),
                          width: double.infinity,
                          padding: EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Material(
                                child: IconButton(
                                  onPressed: () {
                                    //
                                  },
                                  icon: Icon(MdiIcons.cameraSwitchOutline),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  // Take the Picture in a try / catch block. If anything goes wrong,
                                  // catch the error.
                                  try {
                                    // Ensure that the camera is initialized.
                                    await initializeControllerFuture;

                                    // Construct the path where the image should be saved using the
                                    // pattern package.
                                    final String path = join(
                                      // Store the picture in the temp directory.
                                      // Find the temp directory using the `path_provider` plugin.
                                      (await getTemporaryDirectory()).path,
                                      '${DateTime.now()}.png',
                                    );

                                    // Attempt to take a picture and log where it's been saved.
                                    await controller.takePicture(path);

                                    // If the picture was taken, display it on a new screen.
                                    Navigator.pop(context, path);
                                  } catch (e) {
                                    // If an error occurs, log the error to the console.
                                    print(e);
                                  }
                                },
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Material(
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context, 'cancelled');
                                  },
                                  icon: Icon(MdiIcons.closeCircle),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      top: 0,
                      right: 20,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              maxWidth: 500,
                            ),
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            child: Center(
                              child: Text(
                                UserFeedBackTexts.steadyDevice,
                                style: TextThemes.boldSize14Text(Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Otherwise, display a loading indicator.
              return Center(
                child: silLoader,
              );
            }
          },
        ),
      );
    },
    fullscreenDialog: true,
  ));
}
