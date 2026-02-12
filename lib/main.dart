import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'home_page.dart';
import 'login_page.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox('receipts');
  var settingsBox = await Hive.openBox('settings');

  bool initialDarkMode = settingsBox.get('isDarkMode', defaultValue: false);

  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getString('userId') != null;

  runApp(FaturaeApp(
    initialDarkMode: initialDarkMode, 
    isLoggedIn: isLoggedIn
  ));
}

class FaturaeApp extends StatefulWidget {
  final bool initialDarkMode;
  final bool isLoggedIn;

  const FaturaeApp({
    super.key, 
    required this.initialDarkMode, 
    required this.isLoggedIn
  });

  @override
  State<FaturaeApp> createState() => _FaturaeAppState();
}

class _FaturaeAppState extends State<FaturaeApp> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box box, _) {
        final isDark = box.get('isDarkMode', defaultValue: widget.initialDarkMode);

        return MaterialApp(
          title: 'QuantoVaiDar?',
          debugShowCheckedModeBanner: false,

          locale: const Locale('pt', 'BR'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
          ],

          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4C86D9),
              brightness: Brightness.light,
              surface: Colors.white,
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFFF5F7FA),
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            cardTheme: const CardThemeData(color: Colors.white),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4C86D9),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
            ),
            useMaterial3: true,
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF121212),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: const CardThemeData(color: Color(0xFF1E1E1E)),
            dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF1E1E1E)),
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: const Color(0xFF1E1E1E),
              indicatorColor: const Color(0xFF4C86D9).withValues(alpha: 0.5),
              iconTheme: WidgetStateProperty.all(const IconThemeData(color: Colors.white)),
              labelTextStyle: WidgetStateProperty.all(const TextStyle(color: Colors.white)),
            ),
          ),
          home: _isLoggedIn ? const HomePage() : const LoginPage(),
        );
      },
    );
  }
}
