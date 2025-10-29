import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_syakyou/article.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ApiService {
  Future<List<Article>> search(String key) async {
    final uri = Uri.https('qiita.com', '/api/v2/items', {
      'query': 'title:$key',
      'per_page': '10',
    });
    final token = dotenv.env['QIITA_ACCESS_TOKEN'] ?? '';
    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> body = jsonDecode(res.body);
      return body.map((dynamic json) => Article.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}

Future<void> main(List<String> args) async {
  await dotenv.load(fileName: '.env'); // 単体で動かすため仕方なく入れておく
  final logger = Logger();
  final service = ApiService();
  final articles = await service.search('android');
  logger.w("hello!!");
  for (var article in articles) {
    logger.i(article.title);
  }
}
