import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:meilisearch/meilisearch.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fluent_icons;
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

class _MyHomePageState extends State<MyHomePage> {
  var index = MeiliSearchClient(
          dotenv.env['MEILISEARCH_PORT']!.isEmpty
              ? dotenv.env['MEILISEARCH_URL']!
              : "${dotenv.env['MEILISEARCH_URL']!}:${dotenv.env['MEILISEARCH_PORT']!}",
          dotenv.env['MEILISEARCH_API_KEY']!)
      .index(dotenv.env['MEILISEARCH_INDEX']!);

  final _controller = TextEditingController();
  bool _hoversAppBarButton = false;
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
    var result = await index.search(term);
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
    await showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(title: Center(child: Text(title)), children: [
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
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.only(top: 20, bottom: 20)),
                ),
                child: const Text("Zurück")),
            )
            
          ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            MaxGap(MediaQuery.of(context).size.height * 0.05),
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
                    suffixIcon: _controller.value.text!="" ? IconButton(
                        onPressed: _controller.clear,
                        icon: const Icon(fluent_icons.FluentIcons.delete_12_regular)): SizedBox.shrink(),
                    border: const OutlineInputBorder()),
                onChanged: (val) {
                  searchWrapper(val);
                },
              ),
            ),
            MaxGap(20),
            IconButton(onPressed: () {},
            highlightColor: Colors.transparent, //Theme.of(context).colorScheme.secondary.withAlpha(255),
            hoverColor: Theme.of(context).colorScheme.secondary,
             icon: Icon(fluent_icons.FluentIcons.settings_16_filled),
            ),
              ],
            ),
            MaxGap(10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              TextButton(onPressed: () {}, child: Text("Filter")),
            ],),
            const MaxGap(20),
            FutureBuilder(
                future: _ergebnisse,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<GestureDetector> scrollitems = [];
                    for (int i = 0; i < snapshot.data!.length - 1; i++) {
                      var citem = snapshot.data![i];
                      scrollitems.add(GestureDetector(
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
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.only(left: 10, bottom: 10),
                                child:
                                    Text(citem.content.replaceAll("\\n", "\n")),
                              )
                            ],
                          ),
                        ),
                      ));
                    }
                    if (scrollitems.isEmpty) {
                      return SizedBox(
                        height: MediaQuery.sizeOf(context).height*0.85,
                        child: Text("Keine Ergebnisse")
                      );
                    }
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.85,
                      child: ListView(
                        children: scrollitems,
                      ),
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
                    return const CircularProgressIndicator();
                  }
                })
          ],
        ),
      ),
    );
  }
}
