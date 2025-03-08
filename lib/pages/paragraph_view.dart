import 'package:fluent_ui/fluent_ui.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rechtssuche/models/gesetz.dart';

class ParagraphView extends StatefulWidget {
  Gesetz gesetz;
  ParagraphView({super.key, required this.gesetz});

  @override
  _ParagraphViewState createState() => _ParagraphViewState();
}

class _ParagraphViewState extends State<ParagraphView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(text: "${widget.gesetz.gesetzname} ${widget.gesetz.paragraph} ${widget.gesetz.name}"),
          textAlign: TextAlign.center,
          textScaler: TextScaler.linear(3),
        ),
        Expanded(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: SelectableText(widget.gesetz.absaetze.replaceAll("\n", "\n\n"), style: TextStyle(fontSize: 16)),
      ),
        ),
        Gap(10),
        FilledButton(
            child: Text("Zurück"),
            onPressed: () {
              context.go('/');
            },
            style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.only(bottom: 10, top: 10, left: 20, right: 20)))),
            Gap(10),
      ],
    );
  }
}
