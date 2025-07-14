import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunecrate/generated/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:restart_app/restart_app.dart';
import 'globals.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsSetting = true;
  String? userEmail;
  String? userPassword;
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsSetting = prefs.getBool('notifications') ?? true;
      userEmail = prefs.getString('user_email');
      userPassword = prefs.getString('user_password');
      isLoggedIn.value = prefs.getBool('logged_in') ?? isLoggedIn.value; // safe fallback
      selectedLanguage = prefs.getString('lang') ?? 'en';
    });
  }

void _showAboutBox() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)?.aboutApp ?? "About App"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🎵 TuneCrate v1.0.0", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("Developed by Mohsin."),
          SizedBox(height: 8),
          Text("TuneCrate is a simple and lightweight music player for offline and online audio lovers. Build your playlists, favorite tracks, and enjoy a clean interface with smooth playback."),
          SizedBox(height: 12),
          Text("For help, contact us at: tunecrateteam@gmail.com"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}


void _showHelpBox() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(AppLocalizations.of(context)?.help ?? "Help"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text("❓ Frequently Asked Questions", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text("• How to add a song to Favorites?\n→ Tap the heart icon next to the song."),
          SizedBox(height: 6),
          Text("• Can I use the app offline?\n→ No, TuneCrate requires an internet connection to stream music and previews."),
          SizedBox(height: 6),
          Text("• What is the song preview duration?\n→ Each track includes a 30-second preview clip."),
          SizedBox(height: 6),
          Text("• For help, contact us at: tunecrateteam@gmail.com"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)?.profileInfo ?? "Profile Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Username: ${userEmail?.split('@').first ?? "Not Available"}'),
            Text('${AppLocalizations.of(context)?.email ?? "Email"}: ${userEmail ?? "Not Available"}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
void _showChangePasswordDialog() {
  final emailController = TextEditingController();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();

  bool isWrongDetails = false;
  bool isLoading = false;

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Change Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Old Password",
                  errorText: isWrongDetails ? 'Invalid email or password' : null,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showForgotPasswordBox(); // Opens forgot password modal
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);

                      final email = emailController.text.trim();
                      final oldPass = oldPasswordController.text.trim();
                      final newPass = newPasswordController.text.trim();

                      try {
                        // Sign in again to verify credentials
                        final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: oldPass,
                        );

                        final user = userCredential.user;

                        if (user != null) {
                          await user.updatePassword(newPass);

                          // Save updated info locally
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('user_email', email);
                          await prefs.setString('user_password', newPass);

                          setState(() {
                            userEmail = email;
                            userPassword = newPass;
                          });
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ Password updated successfully")),
                          );
                        }
                      // ignore: unused_catch_clause
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          isWrongDetails = true;
                          isLoading = false;
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Update'),
            ),
          ],
        ),
      );
    },
  );
}

void _showForgotPasswordBox() {
  final emailController = TextEditingController();
  bool isSending = false;
  bool emailSent = false;

  showDialog(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Forgot Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your email to receive a password reset link."),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              if (emailSent)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text("✅ Reset email sent!", style: TextStyle(color: Colors.green)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                      setState(() => isSending = true);
                      try {
                        final email = emailController.text.trim();
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                        setState(() => emailSent = true);
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("⚠️ Failed to send reset link: ${e.toString()}")),
                        );
                      }
                      setState(() => isSending = false);
                    },
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text("Confirm"),
            ),
          ],
        ),
      );
    },
  );
}



  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: 450,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.chooseLanguage ?? "Choose Language",
              style: const TextStyle(fontFamily: "Itim", fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _languageTile("English", "en", "🇺🇸"),
                    _languageTile("العربية", "ar", "🇸🇦"),
                    _languageTile("Français", "fr", "🇫🇷"),
                    _languageTile("Español", "es", "🇪🇸"),
                    _languageTile("中文", "zh", "🇨🇳"),
                    _languageTile("हिन्दी", "hi", "🇮🇳"),
                    _languageTile("বাংলা", "bn", "🇧🇩"),
                    _languageTile("Português", "pt", "🇧🇷"),
                    _languageTile("Русский", "ru", "🇷🇺"),
                    _languageTile("日本語", "ja", "🇯🇵"),
                    _languageTile("한국어", "ko", "🇰🇷"),
                    _languageTile("Deutsch", "de", "🇩🇪"),
                    _languageTile("Türkçe", "tr", "🇹🇷"),
                    _languageTile("Bahasa Indonesia", "id", "🇮🇩"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageTile(String title, String code, String flag) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 20)),
      title: Text(title),
      trailing: selectedLanguage == code
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.circle_outlined),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lang', code);
        setState(() => selectedLanguage = code);
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        Restart.restartApp();
      },
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', false);
    setState(() {
      isLoggedIn.value = false;
    });
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Text(text, style: const TextStyle(fontFamily: "Itim", fontWeight: FontWeight.bold, fontSize: 18)),
  );

  Widget _boxTile({
    required String title,
    VoidCallback? onTap,
    Widget? trailing,
    bool disabled = false,
  }) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          constraints: const BoxConstraints(minHeight: 50),
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9),
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontFamily: "Itim", fontSize: 16))),
              if (trailing != null)
                Padding(padding: const EdgeInsets.only(left: 8.0), child: trailing)
              else
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(loc?.settings ?? 'Settings',
            style: const TextStyle(fontFamily: 'Itim', fontSize: 32, color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle( loc?.accountsetting ??"Account Settings"),
          _boxTile(
            title: loc?.profileInfo ?? "Profile Info",
            onTap: isLoggedIn.value ? _showProfileDialog : null,
            disabled: !isLoggedIn.value,
          ),
          _boxTile(
            title: loc?.changePassword ?? "Change Password",
            onTap: isLoggedIn.value ? _showChangePasswordDialog : null,
            disabled: !isLoggedIn.value,
          ),

          _sectionTitle( loc?.langauge ??"Language"),
          _boxTile(title: loc?.language ?? "Language", onTap: _showLanguagePicker),

          _sectionTitle( loc?.notification ??"Notification"),
          _boxTile(
            title: loc?.notifications ?? "Notifications",
            disabled: !isLoggedIn.value,
            trailing: Switch(
              value: notificationsSetting,
              onChanged: isLoggedIn.value
                  ? (val) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('notifications', val);
                      setState(() => notificationsSetting = val);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(val ? "🎵 You’ll get alerts for trending & New songs" : "🔕 You will no longer receive song notifications"),
                        duration: const Duration(seconds: 2),
                      ));
                    }
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: _showAboutBox,
              child: Text(loc?.aboutApp ?? "About App",
                  style: const TextStyle(fontFamily: "Itim", fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 5),
          Center(
            child: GestureDetector(
              onTap: _showHelpBox,
              child: Text(loc?.help ?? "Help",
                  style: const TextStyle(fontFamily: "Itim", fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          if (isLoggedIn.value) const SizedBox(height: 25),
          if (isLoggedIn.value)
            Center(
              child: GestureDetector(
                onTap: _logout,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loc?.logout ?? "Logout",
                        style: const TextStyle(
                            color: Colors.black, fontFamily: "Itim", fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.logout, size: 18, color: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
