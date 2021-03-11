import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sil_themes/spaces.dart';
import 'package:sil_themes/text_themes.dart';

enum BadgeType {
  info,
  danger,
}

class SILBadge extends StatelessWidget {
   const SILBadge({
    required this.text,
    this.type = BadgeType.info,
  });
  final String text;
  final BadgeType type;

 

  @override
  Widget build(BuildContext context) {
    return type == BadgeType.danger
        //error badge
        ? Container(
            padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color:const Color(0xFFE41518).withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(text,
                style: TextThemes.heavySize10Text(const Color(0xFFE41518))),
          )
        //info badge
        : Container(
            padding:const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: getAppGradient(context),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(text,
                style: TextThemes.heavySize10Text(const Color(0xFFFFFFFF))),
          );
  }
}
