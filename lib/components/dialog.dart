import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';

class DialogContent extends StatelessWidget {
  final String title;
  final String content;

  const DialogContent({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
        title: Center(
            child: Column(
          children: [Text(title), Gap(5)],
        )),
        content: Container(
            margin: const EdgeInsets.all(20),
            child: SelectableText(
              content.replaceAll("\n", "\n\n")
            ),
          ),
        actions: [
          Center(child: FilledButton(onPressed: () {
            Navigator.of(context).pop();
          }, child: const Text("Zurück")),)
          
        ],
        );
  }
}
