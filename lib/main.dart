import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:minesort/login/login.dart';
import 'package:minesort/menu/Menu.dart';
import 'package:minesort/utils/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Minesort',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: currentMode,
        home: const MyHomePage(title: 'Minesort: Login'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    getFirebaseToken();
    setupApp();
  }

  setupApp() async {
    await loadSettings();
    MyApp.themeNotifier.value = [ThemeMode.system, ThemeMode.light, ThemeMode.dark][theme];
    if (seckey != "") {
      goToMain();
    }
  }

  Future<void> getFirebaseToken() async {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      final firebaseMessaging = FirebaseMessaging.instance;
      await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      firebase = (await firebaseMessaging.getToken(
        vapidKey:
        'BBziWBf4BbQVAwRico_kn_aOzFXZENinHre13XKtCQ0emsbZ7enZ61lhADCG7j6INMKF0AsmOaOulNy6UFU7OCQ',
      ))!;
    } catch (_) {
      await getFirebaseToken();
    }
  }

  void goToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (BuildContext context) => const CupertinoTabBarDemo()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return login().build(context);
  }
}
