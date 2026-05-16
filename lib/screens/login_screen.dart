import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isAccepted = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        
        // Sign in to Firebase
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        final user = userCredential.user;

        // Save User Data to Firestore
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': user.displayName,
            'email': user.email,
            'photoUrl': user.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            'lastSeen': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF2E7D32); // Premium Green from image

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background subtle design
          Positioned(
            top: -100,
            right: -100,
            child: FadeInDown(
              duration: const Duration(milliseconds: 1500),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Animated Icon/Logo
                  FadeInDown(
                    duration: const Duration(milliseconds: 1000),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: AssetImage('assets/icon.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Animated Title
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Xpense Tracker',
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Animated Subtitle
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 400),
                    child: Text(
                      'Smart way to track and control\nyour daily expenses.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  //Checkbox
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 600),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _isAccepted,
                          activeColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isAccepted = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                              children: [
                                const TextSpan(text: 'By continuing, you agree to our '),
                                TextSpan(
                                  text: 'Terms & Privacy',
                                  style: TextStyle(
                                    color: themeColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      launchUrl(Uri.parse('https://surajchaurasia84.github.io/Xpense-Tracker/'));
                                    },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Google Sign In Button
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    delay: const Duration(milliseconds: 700),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      alignment: Alignment.center,
                      child: _isLoading 
                        ? CircularProgressIndicator(color: themeColor)
                        : Opacity(
                            opacity: _isAccepted ? 1.0 : 0.5,
                            child: GestureDetector(
                              onTap: _isAccepted ? _signInWithGoogle : null,
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    if (_isAccepted)
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                  ],
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/google_logo.png',
                                      height: 24,
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
