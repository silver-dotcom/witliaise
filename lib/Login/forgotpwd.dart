import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sample/Login/LoginPage.dart';

class Forgotpwd extends StatefulWidget {
  const Forgotpwd({Key? key}) : super(key: key);

  @override
  State<Forgotpwd> createState() => _ForgotpwdState();
}

class _ForgotpwdState extends State<Forgotpwd> {
  final formkey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  String pn = '', email = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                child: Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * 0.586,
          width: MediaQuery.of(context).size.width,
          child: Image.asset(
            'images/loginpage.png',
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.all(15),
          child: TextField(
            cursorColor: Colors.black12,
            onChanged: (value) {
              email = value;
            },
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.amber, width: 2),
              ),
              border: OutlineInputBorder(),
              labelText: 'Email',
              floatingLabelStyle: TextStyle(
                color: Colors.amber.shade700,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              hintText: 'Enter Your Email',
            ),
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFFFFD900),
                          Color(0xFFFADE3E),
                          Color(0xFFFFF700),
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      primary: Colors.black54,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Send Password'),
                    onPressed: resetPassword,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(color: Colors.black12),
                ),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(10),
                      primary: Colors.black54,
                      textStyle: const TextStyle(fontSize: 20),
                    ),
                    child: const Text('Back'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ))));
  }

  Future resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      Navigator.pushNamed(context, 'login');
      ScaffoldSnackbar.of(context).show('Password reset email sent');
    } catch (e) {
      ScaffoldSnackbar.of(context).show('Enter a valid email!');
    }
  }
}
