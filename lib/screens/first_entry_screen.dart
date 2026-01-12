import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';
import 'main_screen.dart';

class FirstEntryScreen extends StatefulWidget {
  const FirstEntryScreen({super.key});

  @override
  State<FirstEntryScreen> createState() => _FirstEntryScreenState();
}

class _FirstEntryScreenState extends State<FirstEntryScreen> {
  bool _notificationsEnabled = false;

  Future<void> _onLetsStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.firstEntryKey, true);
    await prefs.setBool(AppConstants.notificationsKey, _notificationsEnabled);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(CupertinoPageRoute(builder: (_) => const MainScreen()));
  }

  Future<void> _openPrivacyPolicy() async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openTermsOfUse() async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse(AppConstants.termsOfUseUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final contentStartHeight = screenHeight * 0.5;

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/welcome.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 0.6, 1.0],
                colors: [
                  const Color(0xFF1A1A1A).withValues(alpha: 0),
                  const Color(0xFF1A1A1A).withValues(alpha: 0.3),
                  const Color(0xFF1A1A1A).withValues(alpha: 0.85),
                  const Color(0xFF1A1A1A),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height:
                      contentStartHeight - MediaQuery.of(context).padding.top,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontFamily: '.SF Pro Display',
                                    fontSize: 72,
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
                        Text(
                          'Most impulses fade within hours.\nGive yourself time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            fontStyle: FontStyle.italic,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.bell_fill,
                              color: AppColors.accent,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Notifications',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                            CupertinoSwitch(
                              value: _notificationsEnabled,
                              activeTrackColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() => _notificationsEnabled = value);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: CupertinoButton(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                            onPressed: _onLetsStart,
                            child: const Text(
                              'LETS START',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.white.withValues(alpha: 0.7),
                              decoration: TextDecoration.none,
                            ),
                            children: [
                              const TextSpan(text: 'by proceeding you\n'),
                              const TextSpan(text: 'accept our '),
                              TextSpan(
                                text: 'terms of use',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.accent,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _openTermsOfUse,
                              ),
                              const TextSpan(text: ' and '),
                              TextSpan(
                                text: 'privacy policy',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.accent,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _openPrivacyPolicy,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
