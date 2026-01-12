import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import 'first_entry_screen.dart';
import 'main_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  double _progress = 0.0;
  final Random _random = Random();
  Timer? _timer;
  late int _totalDurationMs;
  int _elapsedMs = 0;

  @override
  void initState() {
    super.initState();
    _totalDurationMs = AppConstants.loadingDuration.inMilliseconds;
    _startLoading();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLoading() {
    const tickInterval = 50;
    _timer = Timer.periodic(const Duration(milliseconds: tickInterval), (
      timer,
    ) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      _elapsedMs += tickInterval;
      final targetProgress = _elapsedMs / _totalDurationMs;
      final jitter = (_random.nextDouble() - 0.5) * 0.05;
      final newProgress = (targetProgress + jitter).clamp(0.0, 1.0);

      setState(() {
        if (_elapsedMs >= _totalDurationMs) {
          _progress = 1.0;
        } else {
          _progress = newProgress.clamp(_progress, 1.0);
        }
      });

      if (_progress >= 1.0) {
        timer.cancel();
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final firstEntryCompleted =
        prefs.getBool(AppConstants.firstEntryKey) ?? false;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (_) =>
            firstEntryCompleted ? const MainScreen() : const FirstEntryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.825;

    return CupertinoPageScaffold(
      child: Container(
        color: const Color(0xFF141414),
        child: Stack(
          children: [
            Positioned(
              top: screenHeight * 0.1,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_ic_womanmain.png',
                    width: imageWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.55,
              left: 0,
              right: 0,
              child: Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: '.SF Pro Display',
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          height: 1.0,
                          letterSpacing: 0,
                          decoration: TextDecoration.none,
                        ),
                        children: [
                          TextSpan(
                            text: 'buy ',
                            style: TextStyle(color: AppColors.white),
                          ),
                          TextSpan(
                            text: 'better',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -16,
                      right: 42,
                      child: Image.asset(
                        'assets/images/Vector 3.png',
                        width: 96,
                        height: 22,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.065,
              left: 40,
              right: 40,
              child: Column(
                children: [
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: AppColors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
