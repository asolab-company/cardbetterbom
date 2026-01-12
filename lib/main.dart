import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/loading_screen.dart';

void main() {
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
      home: const LoadingScreen(),
    );
  }
}
