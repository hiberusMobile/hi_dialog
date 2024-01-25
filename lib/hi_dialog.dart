library hi_dialog;

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

export 'hi_progress_dialog.dart';

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
  final result = await _showGenericDialog(
      context: context,
      title: Text(title ?? '', style: titleStyle),
      body:
          List.generate(ubody.length, (i) => Text(ubody[i], style: bodyStyle)),
      actionLabels: [
        (
          label: Text(okLabel ?? '', style: okStyle),
          style: okButtonStyle,
          result: OkCancelResult.ok
        ),
        (
          label: Text(cancelLabel ?? '', style: cancelStyle),
          style: cancelButtonStyle,
          result: OkCancelResult.cancel
        )
      ]);
  return result ?? OkCancelResult.cancel;
}

Future<void> hiShowOkAlertDialog({
  required BuildContext context,
  String? title,
  TextStyle? titleStyle,
  List<String>? body,
  TextStyle? bodyStyle,
  String? okLabel,
  TextStyle? okStyle,
  ButtonStyle? okButtonStyle,
}) async {
  var ubody = body ?? [];
  await _showGenericDialog(
      context: context,
      title: Text(title ?? '', style: titleStyle),
      body:
          List.generate(ubody.length, (i) => Text(ubody[i], style: bodyStyle)),
      actionLabels: [
        (
          label: Text(okLabel ?? 'Ok', style: okStyle),
          style: okButtonStyle,
          result: OkCancelResult.ok
        )
      ]);
  return;
}

typedef ActionTuple = ({
  Widget label,
  ButtonStyle? style,
  OkCancelResult result
});

Future<OkCancelResult?> _showGenericDialog({
  required BuildContext context,
  required Widget title,
  required List<Widget> body,
  required List<ActionTuple> actionLabels,
}) async {
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
          for (int i = 0; i < actionLabels.length; i++)
            TextButton(
              style: actionLabels[i].style,
              onPressed: () {
                Navigator.of(context).pop(actionLabels[i].result);
              },
              child: actionLabels[i].label,
            ),
        ],
      );
    },
  );
}
