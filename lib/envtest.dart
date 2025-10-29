import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main(List<String> args) async {
  await dotenv.load(fileName: '.env');
  final String? token = dotenv.env['QIITA_ACCESS_TOKEN'];
  print(token);
}
