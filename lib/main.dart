import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'models/card_model.dart';
import 'screens/home_page.dart';
import 'widgets/unlock_pin_screen.dart';
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
  bool _isUnlocked = false;
  ThemeMode _themeMode = ThemeMode.system;
  final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> pinEnabledNotifier = ValueNotifier<bool>(false);
  String? _pin;
  final PinLockService _pinLockService = PinLockService();
  DateTime? _lastPausedTime;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isPinDialogShowing = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _loadPinState();
    _loadBiometricState();
    WidgetsBinding.instance.addObserver(this);
    // Prompt for auth on app start
    WidgetsBinding.instance.addPostFrameCallback((_) => _promptAuthIfNeeded());
  }

  Future<void> _loadBiometricState() async {
    final box = await Hive.openBox('settingsBox');
    final enabled = box.get('biometricEnabled', defaultValue: false);
    setState(() {
      _biometricEnabled = enabled;
    });
  }

  Future<void> _promptAuthIfNeeded({bool force = false}) async {
    if (_isPinDialogShowing) {
      return;
    }
    if (_isUnlocked && !force) {
      return;
    }
    final navContext = _navigatorKey.currentState?.context;
    if (navContext == null) {
      return;
    }
    await _loadBiometricState();
    await _loadPinState();
    if (_biometricEnabled) {
      final localAuth = LocalAuthentication();
      bool canCheck = await localAuth.canCheckBiometrics;
      bool isAvailable = await localAuth.isDeviceSupported();
      if (canCheck && isAvailable) {
        bool authenticated = false;
        try {
          authenticated = await localAuth.authenticate(
            localizedReason: 'Authenticate to unlock the app',
            options: const AuthenticationOptions(
              biometricOnly: true,
              stickyAuth: true,
            ),
          );
        } catch (e) {
          // Ignore biometric errors
        }
        if (authenticated) {
          _isUnlocked = true;
          return;
        }
      } else {}
    }
    // If PIN is enabled, show PIN screen
    if (pinEnabledNotifier.value || force) {
      _isPinDialogShowing = true;
      final context = navContext;
      if (context.mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (context) => UnlockPinScreen(
              onCancel: () {
                if (mounted) {
                  Navigator.of(context).pop();
                }
                _isPinDialogShowing = false;
              },
            ),
          ),
        );
      }
      if (mounted) {
        _isPinDialogShowing = false;
        _isUnlocked = true;
      }
    } else {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _lastPausedTime = DateTime.now();
      _isUnlocked = false;
    } else if (state == AppLifecycleState.resumed) {
      if (_lastPausedTime != null) {
        final timerMinutes = await _pinLockService.getPinLockTimerMinutes();
        final elapsed = DateTime.now().difference(_lastPausedTime!).inMinutes;
        if (timerMinutes == 0 || elapsed >= timerMinutes) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _promptAuthIfNeeded(),
          );
        }
      }
    }
  }

  Future<void> _loadPinState() async {
    final enabled = await _pinLockService.isPinEnabled();
    final pin = await _pinLockService.getPin();
    pinEnabledNotifier.value = enabled;
    setState(() {
      _pin = pin;
    });
  }

  Future<void> setPinEnabled(bool enabled, [String? pin]) async {
    if (enabled && pin != null && pin.isNotEmpty) {
      try {
        await _pinLockService.setPin(pin);
        pinEnabledNotifier.value = true;
        setState(() {
          _pin = pin;
        });
      } catch (e) {
        pinEnabledNotifier.value = false;
        setState(() {
          _pin = null;
        });
      }
    } else {
      try {
        await _pinLockService.disablePin();
        pinEnabledNotifier.value = false;
      } catch (e) {
        pinEnabledNotifier.value = true;
      }
      setState(() {
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
          isDarkModeNotifier.value = false;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          isDarkModeNotifier.value = true;
          break;
        default:
          _themeMode = ThemeMode.system;
          // Use platformDispatcher instead of deprecated window
          final brightness = View.of(
            context,
          ).platformDispatcher.platformBrightness;
          isDarkModeNotifier.value = brightness == Brightness.dark;
      }
    });
  }

  void toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
      isDarkModeNotifier.value = _themeMode == ThemeMode.dark;
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
    return ValueListenableBuilder<bool>(
      valueListenable: pinEnabledNotifier,
      builder: (context, pinEnabled, _) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
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
            isDarkModeNotifier: isDarkModeNotifier,
            pinEnabled: pinEnabled,
            pin: _pin,
            setPinEnabled: setPinEnabled,
            pinEnabledNotifier: pinEnabledNotifier,
          ),
        );
      },
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
  final FocusNode _pinFocusNode = FocusNode();
  String? _error;

  Future<void> _checkPin() async {
    final box = await Hive.openBox('settingsBox');
    final savedPin = box.get('pin');
    if (_pinController.text == (savedPin?.toString() ?? '')) {
      if (mounted) {
        _pinFocusNode.unfocus();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onUnlock();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _error = 'Incorrect PIN';
        });
      }
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
                focusNode: _pinFocusNode,
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
