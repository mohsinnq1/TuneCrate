import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:tunecrate/globals.dart';
import 'package:tunecrate/main.dart';
import 'reset_password_page.dart';
import 'sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
@override
void initState() {
  super.initState();
  FirebaseAuth.instance; // ✅ this is safe here
}
void _login() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
debugPrint('✅ Logged in successfully');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setBool('logged_in', true);
      await prefs.setInt('last_tab', 3);

      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => HomePage(songs: globalSongs, initialIndex: 3)),
      );
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEAEAEA), Color(0xFFBFD4E3)],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 28),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setInt('last_tab', 3);
                              Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HomePage(
                                    songs: globalSongs,
                                    initialIndex: 3,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text("TuneCrate",
                            style: TextStyle(
                                fontFamily: "Itim",
                                fontSize: 30,
                                fontWeight: FontWeight.bold)),
                        const Text("Log In",
                            style: TextStyle(
                                fontFamily: "Itim", fontSize: 25)),
                        const SizedBox(height: 100),
                        _inputField("EMAIL:", emailController),
                        const SizedBox(height: 20),
                        _inputField("PASSWORD:", passwordController,
                            obscure: true),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
  );
},
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                fontFamily: "Itim",
                                color: Colors.black87,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E6472),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Log In',
                            style: TextStyle(fontFamily: "Itim", fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: "Itim",
                              color: Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                            children: [
                              const TextSpan(
                                  text: "Don't Have An Account? "),
                              TextSpan(
                                text: "SIGNUP",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignupPage(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

 Widget _inputField(String label, TextEditingController controller, {bool obscure = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontFamily: "Itim",
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black54),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              obscureText: obscure,
              style: const TextStyle(fontFamily: "Itim"),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Enter Here',
                hintStyle: TextStyle(
                  fontFamily: "Itim",
                  color: Colors.black54,
                ),
                border: InputBorder.none,
              ),
            ),
            const Divider(thickness: 1, color: Colors.black54),
          ],
        ),
      ),
    ],
  );
}
}