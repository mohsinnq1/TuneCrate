import 'package:flutter/material.dart';
import 'package:tunecrate/generated/app_localizations.dart';
import 'sign_in.dart';
import 'login.dart';

class GuestExplore extends StatelessWidget {
  const GuestExplore({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                loc?.downloads ??
                'Explore',
                style: const TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(thickness: 1, indent: 40, endIndent: 40),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 100),
              child: Text(
                loc?.downloaddescription ??
                "Online downloads are available only\n"
                "to registered users. Log in or\n"
                "sign up to continue.!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(height: 5),
            _buildActionButton(
              label:loc?.signUp ?? "Sign Up",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(loc?.or ??
            "OR", style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            _buildActionButton(
              label:loc?.logInButton ?? "Log in",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
            const SizedBox(height: 130),
            const Divider(thickness: 1, indent: 40, endIndent: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFDCDCDC),
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Colors.black),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Itim',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
