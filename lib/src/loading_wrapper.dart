import 'package:flutter/material.dart';
import 'package:shared_themes/constants.dart';
import 'package:shared_themes/spaces.dart';

class LoadingWrapper extends StatelessWidget {
  const LoadingWrapper({required this.loader});

  final Widget loader;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: <Widget>[
            loader,
            smallVerticalSizedBox,
            const Text(UserFeedBackTexts.savingFile)
          ],
        ),
      ),
    );
  }
}
