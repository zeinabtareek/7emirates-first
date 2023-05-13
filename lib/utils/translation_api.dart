import 'dart:convert';
import 'dart:developer';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';
import 'package:sevenemirates/utils/const.dart';

class TranslationApi {
  static final _apiKey = Const.TRANSLATION_TOKEN;

  static Future<String> translate(String message, String toLanguageCode) async {
    var url =
        'https://translation.googleapis.com/language/translate/v2?target=$toLanguageCode&key=$_apiKey&q=$message';
    log(url, name: 'url');
    final response = await http.post(Uri.parse(
      url,
    ));
    log('${response.body}', name: 'body');

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final translations = body['data']['translations'] as List;
      final translation = translations.first;

      return HtmlUnescape().convert(translation['translatedText']);
    } else {
      throw Exception();
    }
  }

  static Future<String> translate2(
      String message, String fromLanguageCode, String toLanguageCode) async {
    final translation = await GoogleTranslator().translate(
      message,
      from: fromLanguageCode,
      to: toLanguageCode,
    );

    return translation.text;
  }
}
