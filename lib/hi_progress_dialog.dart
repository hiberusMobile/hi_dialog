import 'package:flutter/material.dart';

enum DialogStatus { opened, closed, completed }

class HiProgressDialog {
  final ValueNotifier _progressNotifier = ValueNotifier(0);
  late ValueNotifier _messageNotifier;
  final BuildContext context;
  bool _dialogIsOpen = false;
  ValueChanged<DialogStatus>? _onStatusChanged;

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
      Navigator.pop(context);
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
    ValueChanged<DialogStatus>? onStatusChanged,
  }) {
    _onStatusChanged = onStatusChanged;
    _dialogIsOpen = true;
    _setDialogStatus(DialogStatus.opened);

    return showDialog<void>(
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      context: context,
      builder: (context) => PopScope(
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
                if (closeAtCompleted) close(delay: 1000);
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
                  hideValue == false
                      ? Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            value <= 0 ? '' : '${_progressNotifier.value}/$max',
                            style: TextStyle(
                              decoration: value == max
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        )
                      : const SizedBox.shrink()
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
