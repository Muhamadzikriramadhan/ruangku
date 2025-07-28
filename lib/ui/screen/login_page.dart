import 'package:flutter/material.dart';
import 'package:ruangku/ui/screen/admin_page.dart';
import 'package:ruangku/ui/screen/patient_page.dart';
import 'package:ruangku/ui/theme/colors.dart';

import '../../service/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  final authService = AuthService();

  Future<void> login() async {
    try {
      setState(() => loading = true);
      await authService.signIn(emailController.text, passwordController.text);
      final user = await authService.getCurrentUserModel();

      if (user == null) {
        throw Exception("User data tidak ditemukan.");
      }

      if (user.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminPage(userModel: user)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PatientPage(user: user)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login gagal: ${e.toString()}")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(backgroundColor: appColor,title: Text('Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/icon_ruangku.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            loading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: Text("Login")),
          ],
        ),
      ),
    );
  }
}
