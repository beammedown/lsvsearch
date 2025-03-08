import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:rechtssuche/models/gesetz.dart';

class ParagraphView extends StatefulWidget {
  final Gesetz gesetz;
  const ParagraphView({super.key, required this.gesetz});

  @override
  _ParagraphViewState createState() => _ParagraphViewState();
}

class _ParagraphViewState extends State<ParagraphView> {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.escape): PopIntent(),
        },
        child: Actions(
            dispatcher: ActionDispatcher(),
            actions: <Type, Action<Intent>>{
              PopIntent: CallbackAction<PopIntent>(
                onInvoke: (PopIntent intent) => context.go('/'),
              ),
            },
            child: Focus(
                autofocus: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                            icon: Icon(FluentIcons.back),
                            onPressed: () {
                              context.go('/');
                            }),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                                text:
                                    "${widget.gesetz.gesetzname} ${widget.gesetz.paragraph} ${widget.gesetz.name}"),
                            textAlign: TextAlign.center,
                            textScaler: TextScaler.linear(3),
                          ),
                        )
                      ],
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(10),
                        child: SelectableText(
                            widget.gesetz.absaetze.replaceAll("\n", "\n\n"),
                            style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    Gap(10),
                    FilledButton(
                        onPressed: () {
                          context.go('/');
                        },
                        style: ButtonStyle(
                            padding: WidgetStatePropertyAll(EdgeInsets.only(
                                bottom: 10, top: 10, left: 20, right: 20))),
                        child: const Text("Zurück")),
                    Gap(10),
                  ],
                ))));
  }
}

class PopIntent extends Intent {}
