import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'pages/index.dart';

Future main() async {
  await dotenv.load(fileName: "./assets/.env");
  runApp(const AppStart());
}
