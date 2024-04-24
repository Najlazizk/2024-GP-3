import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async {
    print(
        "`I am printing email controller`" + _emailController.text.toString());
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim());
  }

  void openSignupScreen() {
    Navigator.of(context).pushReplacementNamed("signupScreen");
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image
                Image.asset(
                  'assets/logo.jpg',
                  height: 150,
                ),
                SizedBox(height: 20), // Adding some space between widgets

                // Title
                Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Subtitle (Add your subtitle widget here)
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 30),

                // Email TextField
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Email'),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Password TextField
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Password'),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Sign in Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: signIn,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 45, 183, 77),
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text(
                        'Sign in',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                    ),
                  ),
                ),
                SizedBox(height: 25),

                // Text: Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not yet a member? ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: openSignupScreen,
                      child: Text(
                        'Sign up Now',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
