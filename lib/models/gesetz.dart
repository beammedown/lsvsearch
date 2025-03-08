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