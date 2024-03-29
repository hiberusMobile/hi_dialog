import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hi_dialog/hi_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //*** Ok only Dialog */
            ElevatedButton(
              onPressed: () => hiShowOkAlertDialog(
                  context: context,
                  body: [
                    "Testing alert dialog line1",
                    "Testing alert dialgo line2"
                  ],
                  okLabel: "Ok",
                  title: "Alert Dialog"),
              child: const Text("Alert dialog"),
            ),
            //Ok/Cancel Dialog
            ElevatedButton(
                onPressed: () {
                  hiShowOkCancelAlertDialog(
                          context: context,
                          body: [
                            "Testing alert dialog line1",
                            "Testing alert dialgo line2"
                          ],
                          okLabel: "Ok",
                          cancelLabel: "Cancel",
                          title: "Ok Cancel Dialog")
                      .then((result) {
                    if (result == OkCancelResult.ok) {
                      hiShowOkAlertDialog(
                          context: context, title: "Ok pressed");
                      return;
                    }
                    hiShowOkAlertDialog(
                        context: context, title: "Cancel pressed");
                  });
                },
                child: const Text("Ok Cancel dialog")),
            //Progress autodismiss dialog
            ElevatedButton(
                onPressed: () async {
                  final hpd =
                      HiProgressDialog(context: context, title: "Progress");
                  int progress = 0;
                  hpd.show(
                    closeAtCompleted: true,
                    hideValue: false,
                    max: 100,
                  );
                  Timer.periodic(const Duration(milliseconds: 25), (timer) {
                    progress++;
                    hpd.update(value: progress);
                    if (progress >= 100) {
                      timer.cancel();
                      //hpd.close(delay: 1000);
                    }
                  });
                },
                child: const Text("Progress dialog")),
            //Progress with close button
            ElevatedButton(
                onPressed: () async {
                  final hpd =
                      HiProgressDialog(context: context, title: "Progress");
                  int progress = 0;
                  hpd.show(
                      closeAtCompleted: false,
                      hideValue: false,
                      max: 100,
                      closeLabel: "Dismiss!");
                  Timer.periodic(const Duration(milliseconds: 25), (timer) {
                    progress++;
                    hpd.update(value: progress);
                    if (progress >= 100) {
                      timer.cancel();
                      //hpd.close(delay: 1000);
                    }
                  });
                },
                child: const Text("Progress dialog with close button")),
            //Progress autodismiss dialog with changin message or title
            ElevatedButton(
              onPressed: () async {
                final hpd =
                    HiProgressDialog(context: context, title: "Progress");
                int progress = 0;
                hpd.show(
                    closeAtCompleted: true,
                    hideValue: false,
                    max: 100,
                    message: "Updating...");
                Timer.periodic(const Duration(milliseconds: 25), (timer) {
                  progress++;
                  hpd.update(
                      value: progress,
                      msg: "Progress $progress",
                      title: "Title $progress");
                  if (progress >= 100) {
                    timer.cancel();
                    //hpd.close(delay: 1000);
                  }
                });
              },
              child:
                  const Text("Progress dialog with updating title and message"),
            ),
            ElevatedButton(
              onPressed: () async {
                final hpd = HiProgressDialog(
                    context: context,
                    title: "Progress",
                    type: ProgressDialogType.infinite);
                hpd.show(
                  message: "Updating...",
                );
                Timer(
                  const Duration(seconds: 10),
                  () => hpd.close(),
                );
              },
              child: const Text(
                  "Progress dialog with infinite progress (10 seconds test)"),
            ),
          ],
        ),
      ),
    );
  }
}
