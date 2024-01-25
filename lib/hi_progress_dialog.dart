import 'package:flutter/material.dart';

enum DialogStatus { opened, closed, completed }

enum ProgressDialogType { finite, infinite }

class HiProgressDialog {
  final ValueNotifier _progressNotifier = ValueNotifier(0);
  late ValueNotifier _messageNotifier;
  late ValueNotifier _titleNotifier;

  final BuildContext context;
  final ProgressDialogType type;
  bool _dialogIsOpen = false;
  ValueChanged<DialogStatus>? _onStatusChanged;

  BuildContext? _localContext;

  HiProgressDialog(
      {required this.context,
      required String title,
      this.type = ProgressDialogType.finite}) {
    _messageNotifier = ValueNotifier("");
    _titleNotifier = ValueNotifier(title);
  }

  void update({int? value, String? msg, String? title}) {
    if (value != null) _progressNotifier.value = value;
    if (msg != null) _messageNotifier.value = msg;
    if (title != null) _titleNotifier.value = title;
  }

  void close({int? delay = 0}) {
    if (delay == 0 || delay == null) {
      _closeDialog();
      return;
    }
    Future.delayed(Duration(milliseconds: delay), () {
      _closeDialog();
    });
  }

  ///[isOpen] Returns whether the dialog box is open.
  bool isOpen() {
    return _dialogIsOpen;
  }

  void _closeDialog() {
    if (_dialogIsOpen) {
      if (_localContext != null) Navigator.pop(_localContext!);
      _dialogIsOpen = false;
      _setDialogStatus(DialogStatus.closed);
    }
  }

  void _setDialogStatus(DialogStatus status) {
    _onStatusChanged?.call(status);
  }

  Future<void> show({
    int max = 100,
    bool closeAtCompleted = true,
    bool hideValue = true,
    String? closeLabel,
    String? message,
    TextStyle? messageStyle,
    ButtonStyle? closeStyle,
    ValueChanged<DialogStatus>? onStatusChanged,
  }) {
    _onStatusChanged = onStatusChanged;
    _dialogIsOpen = true;
    _setDialogStatus(DialogStatus.opened);

    return showDialog<void>(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (localContext) {
        _localContext = localContext;
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: ValueListenableBuilder(
              valueListenable: _titleNotifier,
              builder: (BuildContext context, dynamic value, Widget? child) =>
                  Text(value),
            ),
            content: ValueListenableBuilder(
              valueListenable: _progressNotifier,
              builder: (BuildContext context, dynamic value, Widget? child) {
                if (value >= max) {
                  _setDialogStatus(DialogStatus.completed);
                  if (closeAtCompleted) {
                    close(delay: 1000);
                  }
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (message != null)
                      ValueListenableBuilder(
                        valueListenable: _messageNotifier,
                        builder: (BuildContext context, dynamic value,
                                Widget? child) =>
                            Text(value, style: messageStyle),
                      ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: type == ProgressDialogType.finite
                                ? _progressNotifier.value / max
                                : null,
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                          visible: closeLabel != null && value >= max,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: TextButton(
                                style: closeStyle,
                                onPressed: () {
                                  if (_localContext != null) {
                                    Navigator.of(_localContext!).pop();
                                  }
                                },
                                child: Text(closeLabel ?? "")),
                          ),
                        ),
                        hideValue == false
                            ? Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  value <= 0
                                      ? ''
                                      : '${_progressNotifier.value}/$max',
                                  style: TextStyle(
                                    decoration: value == max
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
