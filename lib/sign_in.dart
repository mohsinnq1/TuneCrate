import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tunecrate/globals.dart';
import 'package:tunecrate/main.dart';
import 'login.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
@override
void initState() {
  super.initState();
  FirebaseAuth.instance; // ✅ this is safe here
}

void _signUp() async {
  try {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

     final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);
debugPrint('✅ Logged in successfully');
final user = credential.user;


    if (user != null) {
      debugPrint('✅ User is signed in: ${user.uid}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setBool('logged_in', true);
      await prefs.setInt('last_tab', 3);
debugPrint('Signed up: ${user.email}');
debugPrint('globalSongs: ${globalSongs.length}');
      // 🔁 Navigate to HomePage
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => HomePage(songs: globalSongs, initialIndex: 3)),
        
      );
    } else {
      debugPrint('❌ Signup successful but user is null');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup succeeded, but login failed.")),
        
      );
    }
  } on FirebaseAuthException catch (e) {
    String message = 'Signup failed';

    if (e.code == 'email-already-in-use') {
      message = 'This email is already registered.';
    } else if (e.code == 'invalid-email') {
      message = 'Invalid email address.';
    } else if (e.code == 'weak-password') {
      message = 'Password must be at least 6 characters.';
    } else {
      message = e.message ?? 'Unknown Firebase error';
    }

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    debugPrint('🔥 Unexpected error: $e');
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
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
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setInt('last_tab', 3);
                              Navigator.pushReplacement(
                                // ignore: use_build_context_synchronously
                                context,
                                MaterialPageRoute(
                                  builder: (_) => HomePage(
                                      songs: globalSongs, initialIndex: 3),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "TuneCrate",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Itim",
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Sign Up",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontFamily: "Itim", fontSize: 24),
                        ),
                        const SizedBox(height: 50),
                        _inputField("USERNAME:", usernameController),
                        const SizedBox(height: 12),
                        _inputField("EMAIL:", emailController),
                        const SizedBox(height: 12),
                        _inputField("PASSWORD:", passwordController,
                            obscure: true),
                        const SizedBox(height: 30),
                        Center(
                          child: SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3E6472),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontFamily: "Itim",
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
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
                            ),
                            children: [
                              const TextSpan(
                                  text: "Already have an account? "),
                              TextSpan(
                                text: "LOGIN",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginPage()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
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


  Widget _inputField(String label, TextEditingController controller,
      {bool obscure = false}) {
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
          padding: const EdgeInsets.symmetric(horizontal: 15),
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
