import 'package:HFSPL/main.dart';
import 'package:HFSPL/network/networkcalls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'login_page.dart';
import 'my_home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  final DioClient _client = DioClient();
  final platform = const MethodChannel('com.HFSPL/dev_options');
  Timer? _devModeMonitor;
  bool _dialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await _checkDeveloperOptions();
    //   // Remove continuous monitoring - check only at app start
    //   // _startDevModeMonitor();
    // });
    _checkVersionAndProceed();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _devModeMonitor?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Check only when app comes back to foreground
      _checkDeveloperOptions();
    }
  }

  Future<void> _checkVersionAndProceed() async {
    await Future.delayed(const Duration(seconds: 1)); // show splash for a moment

    // 1. Get app version code
    final info = await PackageInfo.fromPlatform();
    final versionCode = int.tryParse(info.buildNumber) ?? 1;
    

    // 2. Call your API
    final resp = await _client.fetchVersion(versionCode);
    if (resp == null) {
      _showError('Something went wrong');
      return;
    }

    // 3. Check device time vs server time
    final serverTime = DateTime.parse(resp.dateTime); // parses ISO 8601 correctly
    final now = DateTime.now(); // consistent timezone
    final diffMinutes = (now.difference(serverTime).inMinutes).abs();

    if (diffMinutes > 5) {
      _showAlert(
        'Date and time is incorrect on your device. Please update and open the app again.',
        exitApp: true,
      );
    }

    // 4. Check for update (compare versionCode from response)
    if (resp.showPopup == true || (resp.versionCode != null && resp.versionCode != info.buildNumber)) {
      if (resp.isUpdateRequired == false) {
        _showUpdateDialog(resp.versionTitle ?? 'Update Available', resp.versionMessage ?? '', canSkip: true);
      } else {
        _showUpdateDialog(resp.versionTitle ?? 'Update Required', resp.versionMessage ?? '', canSkip: false);
      }
      return;
    }

    // 5. Proceed to login/home
    _goToNext();
  }

    Future<void> _checkDeveloperOptions() async {
    try {
      final bool isEnabled = await platform.invokeMethod('isDeveloperOptionsEnabled');
      if (isEnabled) {
        _showBlockDialog();
      }
    } on PlatformException catch (e) {
      // print("Error checking Developer Options: ${e.message}");
    }
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Developer Options Enabled'),
        content: Text('Please disable Developer Options to continue using the app.'),
        actions: [
          TextButton(
            onPressed: () {
              // Optionally close the app or open settings
              SystemNavigator.pop();
            },
            child: Text('Exit'),
          ),
        ],
      ),
    );
  }
  
// Removed: _startDevModeMonitor() - no longer needed
// Now using lifecycle events for better performance

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showAlert(String message, {bool exitApp = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              if (exitApp) {
                // Exit app
                Future.delayed(const Duration(milliseconds: 300), () {
                  SystemNavigator.pop();
                });
              } else {
                Navigator.of(context).pop();
                _goToNext();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(String title, String message, {required bool canSkip}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            child: const Text('Ok'),
          ),
          if (canSkip)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _goToNext();
              },
              child: const Text('Skip'),
            ),
        ],
      ),
    );
  }

  void _goToNext() async {
    // Check login status here
    final myApp = MyApp();
    bool loggedIn = await myApp.isLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => loggedIn
            ? const MyHomePage(title: 'Home page')
            : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Hfspl',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}