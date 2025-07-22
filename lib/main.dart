import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/card_model.dart';
import 'screens/home_page.dart';
import 'constants/app_constants.dart';
import 'services/pin_lock_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(CardModelAdapter());
  await Hive.openBox<CardModel>(AppConstants.cardsBoxKey);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  bool _pinEnabled = false;
  String? _pin;
  final PinLockService _pinLockService = PinLockService();

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // No pin lock screen, so nothing to do here
  }

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadPinState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> _loadPinState() async {
    final enabled = await _pinLockService.isPinEnabled();
    final pin = await _pinLockService.getPin();
    setState(() {
      _pinEnabled = enabled;
      _pin = pin;
    });
  }

  Future<void> setPinEnabled(bool enabled, [String? pin]) async {
    if (enabled && pin != null && pin.isNotEmpty) {
      await _pinLockService.setPin(pin);
      setState(() {
        _pinEnabled = true;
        _pin = pin;
      });
    } else {
      await _pinLockService.disablePin();
      setState(() {
        _pinEnabled = false;
        _pin = null;
      });
    }
  }

  Future<void> _loadThemeMode() async {
    final box = await Hive.openBox('settingsBox');
    final modeStr = box.get('themeMode', defaultValue: 'system');
    setState(() {
      switch (modeStr) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }
    });
  }

  void toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
    final box = await Hive.openBox('settingsBox');
    box.put(
      'themeMode',
      _themeMode == ThemeMode.light
          ? 'light'
          : _themeMode == ThemeMode.dark
          ? 'dark'
          : 'system',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.indigo.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigoAccent,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.indigo.shade900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.indigo,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
      ),
      home: HomePage(
        title: AppConstants.appName,
        toggleTheme: toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
        pinEnabled: _pinEnabled,
        pin: _pin,
        setPinEnabled: setPinEnabled,
      ),
    );
  }
}

// Simple PIN lock screen widget
class PinLockScreen extends StatefulWidget {
  final VoidCallback onUnlock;
  const PinLockScreen({super.key, required this.onUnlock});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController _pinController = TextEditingController();
  String? _error;

  Future<void> _checkPin() async {
    final box = await Hive.openBox('settingsBox');
    final savedPin = box.get('pin');
    if (_pinController.text == savedPin) {
      widget.onUnlock();
    } else {
      setState(() {
        _error = 'Incorrect PIN';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 48, color: Colors.white),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter PIN',
                  errorText: _error,
                  filled: true,
                  fillColor: Colors.white10,
                  labelStyle: const TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (_) => _checkPin(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _checkPin, child: const Text('Unlock')),
            ],
          ),
        ),
      ),
    );
  }
}
