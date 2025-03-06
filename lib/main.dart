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
  final int id;
  final String gesetzname;
  final String paragraf;
  final String titel;
  final String content;

  const Gesetz({
    required this.id,
    required this.gesetzname,
    required this.paragraf,
    required this.titel,
    required this.content,
  });

  factory Gesetz.fromJson(Map<String, dynamic> json) {
    return Gesetz(
        id: json['id'],
        gesetzname: json['gesetz'],
        paragraf: json['paragraf'],
        titel: json['titel'],
        content: json['Inhalt']);
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
  var index = MeiliSearchClient(
          dotenv.env['MEILISEARCH_PORT']!.isEmpty
              ? dotenv.env['MEILISEARCH_URL']!
              : "${dotenv.env['MEILISEARCH_URL']!}:${dotenv.env['MEILISEARCH_PORT']!}",
          dotenv.env['MEILISEARCH_API_KEY']!)
      .index(dotenv.env['MEILISEARCH_INDEX']!);

  final _controller = TextEditingController();
  final _dropdowncontroller = TextEditingController();

  String filterstring = "";
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

  Future<List<Gesetz>> _ergebnisse = Future.delayed(
    const Duration(seconds: 10),
    () => [],
  );

  @override
  void initState() {
    super.initState();
    _ergebnisse = search("HeschG");
  }

  Future<List<Gesetz>> search(String term) async {
    if (kDebugMode) {
      print("searching: $term");
    }
    var result = await index.search(term, SearchQuery(filter: [filterstring]));
    List<Gesetz> someone = [];
    for (int i = 0; i < result.hits.length - 1; i++) {
      someone.add(Gesetz.fromJson(result.hits[i]));
    }
    return someone;
  }

  Future<void> searchWrapper(String term) async {
    var res = search(term);
    setState(() {
      _ergebnisse = res;
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
                            duration: Durations.medium1,
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
                                      filterstring = "gesetz = $val";
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
                                value: "Heschg",
                                label: "Hessisches Schulgesetz"),
                            DropdownMenuEntry(
                                value: "Sch_StudVtrV", label: "SV Verordnung"),
                            DropdownMenuEntry(value: "OAVO", label: "OAVO"),
                            DropdownMenuEntry(value: "VOGSV", label: "VOGSV"),
                            DropdownMenuEntry(
                                value: "HDigSchulG", label: "HDIGI"),
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
                                "${citem.gesetzname} §${citem.paragraf} ${citem.titel}",
                                citem.content);
                          },
                          child: Card(
                            color: Theme.of(context).colorScheme.primary,
                            elevation: 4,
                            child: Column(
                              children: [
                                Text(
                                  "${citem.gesetzname} §${citem.paragraf} ${citem.titel}",
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
                                    text: citem.content.replaceAll("\\n", "\n"),
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
