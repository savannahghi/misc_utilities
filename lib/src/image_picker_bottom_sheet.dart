import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:misc_utilities/src/asset_strings.dart';

import 'package:misc_utilities/src/bottom_sheet_builder.dart';
import 'package:misc_utilities/src/string_constant.dart';

/// [ImagePickerBottomSheet] is used to show the bottomsheet for selecting the
/// [ImageSource] to use when selecting a file to upload.
///
/// [pickCamera] function is triggered when the camera [ListTile] is tapped,
/// and it opens the camera to take a picture of the image
///
/// [pickGallery] function is triggered to allow the user select an image from
/// their gallery.
///
/// `Navigator.of(context).pop()` is called after [pickCamera] and [pickGallery]
/// to close the bottomsheet automatically
class ImagePickerBottomSheet extends BottomSheetBuilder {
  ImagePickerBottomSheet({
    required this.pickCamera,
    required this.pickGallery,
  });

  final Function pickCamera;
  final Function pickGallery;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 15.0),
              color: Colors.grey[300],
              width: 40,
              height: 4,
            ),
          ),
          ListTile(
            leading: SvgPicture.asset(
              cameraSVGImagePath,
              width: 23,
              height: 23,
            ),
            title: const Text(cameraText),
            onTap: () {
              pickCamera();
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.photo_fill_on_rectangle_fill),
            title: const Text(galleryText),
            onTap: () {
              pickGallery();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
