import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/database_service.dart';
import 'services/security_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Status Bar and Navigation Bar customization
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent, 
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarContrastEnforced: false,
    systemStatusBarContrastEnforced: false,
  ));

  // Enable Edge-to-Edge mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        ChangeNotifierProvider<SecurityService>(create: (_) => SecurityService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Xpense Tracker',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
            useMaterial3: true,
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: ZoomPageTransitionsBuilder(),
                TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
              },
            ),
          ),
        home: const LockWrapper(child: AuthWrapper()),
      ),
    );
  }
}

class LockWrapper extends StatefulWidget {
  final Widget child;
  const LockWrapper({super.key, required this.child});

  @override
  State<LockWrapper> createState() => _LockWrapperState();
}

class _LockWrapperState extends State<LockWrapper> with SingleTickerProviderStateMixin {
  bool _isAuthenticated = false;
  bool _isLockEnabled = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _checkLock();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLock() async {
    final security = SecurityService();
    await security.init(); // Ensure it's loaded from SharedPreferences
    _isLockEnabled = security.isLockEnabledValue;
    
    if (!_isLockEnabled) {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = false);
    _authenticate();
  }

  Future<void> _authenticate() async {
    final security = SecurityService();
    bool success = await security.authenticate();
    if (success) {
      setState(() {
        _isAuthenticated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isLockEnabled && !_isAuthenticated) {
      return Scaffold(
        body: Stack(
          children: [
            // Premium Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8F5E9), Colors.white, Color(0xFFF1F8E9)],
                ),
              ),
            ),
            // Decorative Abstract Shapes
            Positioned(
              top: -50,
              right: -50,
              child: _buildDecorativeCircle(250, const Color(0xFF2E7D32).withOpacity(0.04)),
            ),
            Positioned(
              bottom: 100,
              left: -30,
              child: _buildDecorativeCircle(150, const Color(0xFF2E7D32).withOpacity(0.06)),
            ),
            Positioned(
              top: 200,
              left: -80,
              child: _buildDecorativeCircle(200, const Color(0xFF2E7D32).withOpacity(0.03)),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Breathing Lock Icon
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.15),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.lock_rounded, size: 70, color: Color(0xFF2E7D32)),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Xpense Tracker',
                      style: GoogleFonts.outfit(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1B5E20),
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your finances are secured\nPlease authenticate to continue',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black45,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 70),
                    // Premium Unlock Button
                    GestureDetector(
                      onTap: _authenticate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32).withOpacity(0.4),
                              blurRadius: 25,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fingerprint, color: Colors.white, size: 28),
                            const SizedBox(width: 14),
                            Text(
                              'Unlock App',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return widget.child;
  }

  Widget _buildDecorativeCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the user is logged in, show MainScreen
        if (snapshot.hasData) {
          return const MainScreen();
        }
        // Otherwise, show LoginScreen
        return const LoginScreen();
      },
    );
  }
}
