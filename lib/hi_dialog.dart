library hi_dialog;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

enum OkCancelResult { ok, cancel }

/// Show OK/Cancel alert dialog, customized buttons and text
///
/// This is convenient wrapper of [showDialog].

@useResult
Future<OkCancelResult> hiShowOkCancelAlertDialog({
  required BuildContext context,
  String? title,
  TextStyle? titleStyle,
  List<String>? body,
  TextStyle? bodyStyle,
  String? okLabel,
  TextStyle? okStyle,
  ButtonStyle? okButtonStyle,
  String? cancelLabel,
  ButtonStyle? cancelButtonStyle,
  TextStyle? cancelStyle,
}) async {
  var ubody = body ?? [];
  final result = await _showDialog(
      context,
      Text(title ?? '', style: titleStyle),
      List.generate(ubody.length, (i) => Text(ubody[i], style: bodyStyle)),
      Text(okLabel ?? '', style: okStyle),
      Text(cancelLabel ?? '', style: cancelStyle),
      okButtonStyle,
      cancelButtonStyle);
  return result ?? OkCancelResult.cancel;
}

Future<OkCancelResult?> _showDialog(
  BuildContext context,
  Widget title,
  List<Widget> body,
  Widget okLabel,
  Widget cancelLabel,
  ButtonStyle? okButtonStyle,
  ButtonStyle? cancelButtonStyle,
) async {
  return await showDialog<OkCancelResult>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: title,
        content: SingleChildScrollView(
          child: ListBody(
            children: body,
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: cancelButtonStyle,
            onPressed: () {
              Navigator.of(context).pop(OkCancelResult.cancel);
            },
            child: cancelLabel,
          ),
          TextButton(
            style: okButtonStyle,
            child: okLabel,
            onPressed: () {
              Navigator.of(context).pop(OkCancelResult.ok);
            },
          ),
        ],
      );
    },
  );
}
