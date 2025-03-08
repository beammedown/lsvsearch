import 'dart:async';
import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rechtssuche/pages/paragraph_view.dart';
import 'package:substring_highlight/substring_highlight.dart';
import 'package:gap/gap.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart'
    as fluent_icons;
import '../theme.dart';
import '../models/gesetz.dart';

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(initialLocation: '/', routes: [
      GoRoute(
          path: '/',
          builder: (context, state) {
            return IndexPage();
          },
          routes: [
            GoRoute(
                path: 'p',
                builder: (context, state) {
                  Gesetz gesetz = state.extra as Gesetz;
                  return ParagraphView(gesetz: gesetz);
                })
          ]),
    ]);

    return FluentApp.router(
      theme: fluentThemeData,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  final _searchController = TextEditingController();

  String filterstring = "";
  String _selectedFilter = "Jedes Gesetz";
  List<Gesetz> data = [];
  bool _showfilter = false;
  double _spinit = 0;
  double _animscale = 1;
  double _animatedopacity = 0;

  Future<List<Gesetz>> _ergebnisse = Future.value([]);

  Future<void> _initdata() async {
    final filer =
        await DefaultAssetBundle.of(context).loadString("assets/general.json");

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

  List<Gesetz> search(String term) {
    List<Gesetz> results = [];
    if (filterstring != "") {
      for (var value in data) {
        if (results.length == 20) {
          break;
        }
        if (value.absaetze.toString().contains(term) &&
            value.altname.contains(filterstring)) {
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

  void _comboBoxHandler(String val) {
    switch (val) {
      case "all":
        setState(() {
          _selectedFilter = val;
          filterstring = "";
        });
        searchWrapper(_searchController.text);
        break;
      case "VerfHe":
        setState(() {
          _selectedFilter = val;
          filterstring = val;
        });
        break;
      case "HSchG":
        setState(() {
          _selectedFilter = val;
          filterstring = val;
        });
        break;
      case "OAVO":
        setState(() {
          _selectedFilter = val;
          filterstring = val;
        });
        break;
      case "VOGSV":
        setState(() {
          _selectedFilter = val;
          filterstring = val;
        });
        break;
      case "SV-VO":
        setState(() {
          _selectedFilter = val;
          filterstring = val;
        });
        break;
      default:
        break;
    }
    searchWrapper(_searchController.text);
  }

  @override
  void initState() {
    super.initState();
    _initdata();
    
    searchWrapper("");
  }

  final FocusNode _focy = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
              SearchIntent(),
        },
        child: Actions(
            dispatcher: ActionDispatcher(),
            actions: <Type, Action<Intent>>{
              SearchIntent: CallbackAction<SearchIntent>(
                onInvoke: (intent) => _focy.requestFocus(),
              )
            },
            child: Focus(
                autofocus: true,
                child: ScaffoldPage(
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: TextBox(
                              focusNode: _focy,
                              controller: _searchController,
                              placeholder: "Suche was du möchtest",
                              suffix: _searchController.value.text != ""
                                  ? AnimatedScale(
                                      scale: _animscale,
                                      duration: Duration(milliseconds: 200),
                                      onEnd: () {
                                        setState(() {
                                          _animscale = 1;
                                        });
                                        _searchController.clear();
                                        searchWrapper("");
                                      },
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _animscale = 0.0;
                                            });
                                          },
                                          icon: const Icon(
                                            fluent_icons
                                                .FluentIcons.delete_12_regular,
                                            color:
                                                Color.fromRGBO(40, 40, 40, 1),
                                          )))
                                  : SizedBox.shrink(),
                              prefix: SizedBox(width: 10),
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
                              icon: Icon(
                                  fluent_icons.FluentIcons.settings_16_filled),
                            ),
                          ),
                        ],
                      ),
                      Gap(10),
                      _showfilter
                          ? AnimatedOpacity(
                              duration: Duration(milliseconds: 250),
                              opacity: _animatedopacity,
                              onEnd: () {
                                setState(() {
                                  _showfilter = false;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // TODO: einen Filter einsetzen wieviele Ergebnisse zurückgegeben werden
                                  // TODO: das hier stylen
                                  ComboBox(
                                      value: _selectedFilter,
                                      onChanged: (val) =>
                                          {_comboBoxHandler(val!)},
                                      placeholder: const Text("Jedes Gesetz"),
                                      items: [
                                        ComboBoxItem(
                                            value: "all",
                                            child: Text("Jedes Gesetz")),
                                        ComboBoxItem(
                                            value: "VerfHe",
                                            child:
                                                Text("Hessische Verfassung")),
                                        ComboBoxItem(
                                            value: "HSchG",
                                            child:
                                                Text("Hessisches Schulgesetz")),
                                        ComboBoxItem(
                                            value: "OAVO", child: Text("OAVO")),
                                        ComboBoxItem(
                                            value: "SV-VO",
                                            child: Text("SV-Verordnung")),
                                        ComboBoxItem(
                                            value: "VOGSV",
                                            child: Text("VOGSV"))
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
                                for (int i = 0;
                                    i < snapshot.data!.length - 1;
                                    i++) {
                                  var citem = snapshot.data![i];
                                  scrollitems.add(
                                    GestureDetector(
                                      onTap: () {
                                        context.go('/p', extra: citem);
                                      },
                                      child: Card(
                                        margin: EdgeInsets.all(4.0),
                                        child: Column(
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                  text:
                                                      "${citem.gesetzname} ${citem.paragraph} ${citem.name}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900)),
                                            ),
                                            Gap(5),
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  left: 10, bottom: 10),
                                              child: SubstringHighlight(
                                                text: citem.absaetze
                                                    .replaceAll("\\n", "\n"),
                                                term: _searchController.text,
                                                textStyle: TextStyle(
                                                    color: Colors.white),
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
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.85,
                                      child: Text("Keine Ergebnisse"));
                                }
                                return ListView(
                                  children: scrollitems,
                                );
                              } else if (snapshot.hasError) {
                                return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                          "Etwas ist falsch gelaufen. Neu laden:"),
                                      IconButton(
                                        onPressed: () => searchWrapper(""),
                                        icon: const Icon(fluent_icons
                                            .FluentIcons.sync_off_16_filled),
                                      ),
                                    ]);
                              } else {
                                return ProgressRing();
                              }
                            }),
                      ),
                    ],
                  ),
                ))));
  }
}

class SearchIntent extends Intent {}
