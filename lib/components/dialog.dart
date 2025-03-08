import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DialogContent extends StatelessWidget {
  final String title;
  final String content;

  const DialogContent({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        title: Center(
            child: Column(
          children: [Text(title), Gap(5)],
        )),
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: SelectableText(
              content.replaceAll("\n", "\n\n")
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.8,
            child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.secondary),
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.only(top: 20, bottom: 20)),
                ),
                child: Text(
                  "Zurück",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary),
                )),
          )
        ]);
  }
}
