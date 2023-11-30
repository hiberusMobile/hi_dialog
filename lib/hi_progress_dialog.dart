import 'package:flutter/material.dart';

enum DialogStatus { opened, closed, completed }

class HiProgressDialog {
  final ValueNotifier _progressNotifier = ValueNotifier(0);
  late ValueNotifier _messageNotifier;
  final BuildContext context;
  bool _dialogIsOpen = false;
  ValueChanged<DialogStatus>? _onStatusChanged;

  BuildContext? _localContext;

  HiProgressDialog({required this.context, required String title}) {
    _messageNotifier = ValueNotifier(title);
  }

  void update({int? value, String? msg}) {
    if (value != null) _progressNotifier.value = value;
    if (msg != null) _messageNotifier.value = msg;
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
              valueListenable: _messageNotifier,
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
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: _progressNotifier.value / max,
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
