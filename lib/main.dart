import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meilisearch/meilisearch.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart'
    as fluent_icons;
import 'theme.dart';

Future main() async {
  await dotenv.load(fileName: "./assets/.env");
  runApp(const MyApp());
}

class Gesetz {
  final String absaetze;
  final String name;
  final String paragraph;
  final String gesetzname;
  final String altname;

  const Gesetz({
    required this.absaetze,
    required this.gesetzname,
    required this.name,
    required this.altname,
    required this.paragraph,
  });

  factory Gesetz.fromJson(Map<String, dynamic> json) {
    return Gesetz(
        absaetze: json['absaetze'],
        gesetzname: json['gesetzname'],
        paragraph: json['paragraph'],
        name: json['name'],
        altname: json['altname']);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LSV Rechtssuche',
      theme: ThemeData(
        colorScheme: brightscheme,
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: darkscheme,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'LSV Suche'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _dropdowncontroller = TextEditingController();

  String filterstring = "";
  List<Gesetz> data = [];
  bool _showfilter = false;
  double _spinit = 0;
  double _animscale = 1;
  double _animatedopacity = 0;

  late final AnimationController _slideanimation = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<Offset> _offsetanimation = Tween<Offset>(
          begin: Offset(1.5, 0.0), end: Offset.zero)
      .animate(CurvedAnimation(parent: _slideanimation, curve: Curves.easeIn));

  @override
  void dispose() {
    _slideanimation.dispose();
    super.dispose();
  }

  Future<List<Gesetz>> _ergebnisse = Future.value([]);

  Future<void> _initdata() async {
    final filer = await File("./assets/general.json").readAsString();

    final jsonData = jsonDecode(filer) as List<dynamic>;
    List<Gesetz> dataNew = [];
    for (var item in jsonData) {
      dataNew.add(Gesetz.fromJson(item));
    }
    setState(() {
      data = dataNew;
    });
    return;
  }

  @override
  void initState() {
    super.initState();
    _initdata();

    _ergebnisse = Future.value(search("HeschG"));
  }

  List<Gesetz> search(String term) {
    List<Gesetz> results = [];
    if (filterstring != "") {
      for (var value in data) {
        if (results.length == 20) {
          break;
        }
        if (value.absaetze.toString().contains(term) && value.altname.contains(filterstring)) {
          results.add(value);
        }
      }

      return results;
    }
    for (var value in data) {
      if (results.length == 20) {
        break;
      }
      if (value.absaetze.toString().contains(term)) {
        results.add(value);
      }
    }

    return results;
  }

  void searchWrapper(String term) {
    var res = search(term);

    setState(() {
      _ergebnisse = Future.value(res);
    });
  }

  Future<void> _showSimpleDialog(String title, String content) async {
    _slideanimation.forward();
    await showDialog(
        context: context,
        builder: (context) {
          return SlideTransition(
              position: _offsetanimation,
              child: SimpleDialog(
                  title: Center(
                      child: Column(
                    children: [Text(title), Gap(5)],
                  )),
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      child: SelectableText(
                        content.replaceAll("\\n", "\n\n"),
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
                                color:
                                    Theme.of(context).colorScheme.onSecondary),
                          )),
                    )
                  ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Gap(MediaQuery.of(context).size.height * 0.03),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Suche was du möchtest",
                    suffixIcon: _controller.value.text != ""
                        ? AnimatedScale(
                            scale: _animscale,
                            duration: Durations.short2,
                            onEnd: () {
                              setState(() {
                                _animscale = 1;
                              });
                              _controller.clear();
                              searchWrapper("");
                            },
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _animscale = 1.5;
                                  });
                                },
                                padding: EdgeInsets.only(right: 10),
                                splashColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: const Icon(fluent_icons
                                    .FluentIcons.delete_12_regular)))
                        : SizedBox.shrink(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(40))),
                    prefix: SizedBox(width: 10),
                  ),
                  onChanged: (val) {
                    searchWrapper(val);
                  },
                ),
              ),
              Gap(20),
              AnimatedRotation(
                curve: Curves.elasticOut,
                duration: Duration(seconds: 1),
                turns: _spinit,
                child: IconButton(
                  onPressed: () {
                    if (_spinit == 1) {
                      setState(() {
                        _spinit = 0;
                        _animatedopacity = 0.0;
                      });
                    } else {
                      setState(() {
                        _spinit = 1;
                        _showfilter = true;
                        _animatedopacity = 1.0;
                      });
                    }
                  },
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  style: ButtonStyle(),
                  icon: Icon(fluent_icons.FluentIcons.settings_16_filled),
                ),
              ),
            ],
          ),
          Gap(10),
          _showfilter
              ? AnimatedOpacity(
                  duration: Durations.medium1,
                  opacity: _animatedopacity,
                  onEnd: () {
                    setState(() {
                      _showfilter = false;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // TODO: das hier stylen
                      DropdownMenu(
                          controller: _dropdowncontroller,
                          enableSearch: false,
                          enableFilter: false,
                          onSelected: (val) => {
                                if (val == "all")
                                  {
                                    setState(() {
                                      filterstring = "";
                                    }),
                                    searchWrapper(_controller.text)
                                  }
                                else
                                  {
                                    setState(() {
                                      filterstring = "$val";
                                    }),
                                    searchWrapper(_controller.text)
                                  }
                              },
                          initialSelection: "all",
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                                value: "all", label: "Jedes Gesetz"),
                            DropdownMenuEntry(
                                value: "VerfHe", label: "Hessische Verfassung"),
                            DropdownMenuEntry(
                                value: "HSchG",
                                label: "Hessisches Schulgesetz"),
                            DropdownMenuEntry(
                                value: "SV-VO", label: "SV Verordnung"),
                            DropdownMenuEntry(value: "OAVO", label: "OAVO"),
                            DropdownMenuEntry(value: "VOGSV", label: "VOGSV"),
                            //DropdownMenuEntry(
                            //    value: "HDigSchulG", label: "HDIGI"),
                          ])
                    ],
                  ),
                )
              : Row(),
          Gap(10),
          Expanded(
            child: FutureBuilder(
                future: _ergebnisse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<GestureDetector> scrollitems = [];
                    for (int i = 0; i < snapshot.data!.length - 1; i++) {
                      var citem = snapshot.data![i];
                      scrollitems.add(
                        GestureDetector(
                          onTap: () {
                            _showSimpleDialog(
                                "${citem.gesetzname} ${citem.paragraph} ${citem.name}",
                                citem.absaetze);
                          },
                          child: Card(
                            color: Theme.of(context).colorScheme.primary,
                            elevation: 4,
                            child: Column(
                              children: [
                                Text(
                                  "${citem.gesetzname} ${citem.paragraph} ${citem.name}",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 10),
                                  child: SubstringHighlight(
                                    text:
                                        citem.absaetze.replaceAll("\\n", "\n"),
                                    term: _controller.text,
                                    textStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    if (scrollitems.isEmpty) {
                      return SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.85,
                          child: Text("Keine Ergebnisse"));
                    }
                    return ListView(
                      children: scrollitems,
                    );
                  } else if (snapshot.hasError) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("Etwas ist falsch gelaufen. Neu laden:"),
                          IconButton(
                            onPressed: () => searchWrapper(""),
                            icon: const Icon(Icons.autorenew),
                          ),
                        ]);
                  } else {
                    return Container(child: CircularProgressIndicator());
                  }
                }),
          ),
        ],
      ),
    );
  }
}
