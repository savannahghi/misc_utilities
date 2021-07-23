import 'package:flutter/widgets.dart';

/// [BottomSheetBuilder] defines the blueprint that will be used to build
/// our bottom sheets
///
/// example
///
/// ```dart
///  CoversBottomSheet extends BottomSheetBuilder{
///   CoversBottomSheet()
///      : super(
///          primaryColor: Colors.amber,
///          textColor: Colors.amberAccent,
///          backgroundColor: Colors.black,
///          action: () => true,
///          message: 'test message',
///         # define all arguments you may need here.
///        );
///
///   @override
///   Widget build(BuildContext context){
///     # here you define how you want your bottom sheet to look like. It can be a simple or as complex as you desire
///     return Container();
/// }
/// }
///
///```
///
///After defining the bottom sheet, use the `bottomSheet` function to call it
///
///example
///
///```dart
/// bottomSheet(context: context, builder: CoversBottomSheet())
///
///```
abstract class BottomSheetBuilder {
  BottomSheetBuilder(
      {this.action,
      this.backgroundColor,
      this.textColor,
      this.primaryColor,
      this.isError,
      this.message,
      this.showPrimaryButton,
      this.showSecondaryButton,
      this.showTertiaryButton,
      this.buttonColor,
      this.borderColor,
      this.customPadding,
      this.callback,
      this.primaryButtonCallback,
      this.secondaryActionCallback,
      this.secondaryButtonText,
      this.primaryActionText,
      this.primaryActionCallback,
      this.primaryButtonText,
      this.tertiaryActionCallback,
      this.secondaryButtonCallback,
      this.secondaryActionText,
      this.tertiaryActionText});

  final String? message;
  final Function? action;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? primaryColor;
  final bool? isError;
  bool? showPrimaryButton;
  bool? showSecondaryButton;
  bool? showTertiaryButton;
  Color? buttonColor;
  Color? borderColor;
  EdgeInsets? customPadding;
  Function? callback;
  Function? primaryButtonCallback;
  Function? secondaryButtonCallback;
  String? secondaryButtonText;
  String? primaryButtonText;
  String? primaryActionText;
  Function? primaryActionCallback;
  String? secondaryActionText;
  Function? secondaryActionCallback;
  String? tertiaryActionText;
  Function? tertiaryActionCallback;

  Widget build(BuildContext context);
}
