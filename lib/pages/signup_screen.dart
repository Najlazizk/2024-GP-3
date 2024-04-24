import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreenn extends StatefulWidget {
  const SignupScreenn({super.key});

  @override
  State<SignupScreenn> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreenn> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future signUp() async {
    if (passwordConfirmed()) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      Navigator.of(context).pushNamed("/");
    }
  }

  bool passwordConfirmed() {
    if (_passwordController.text.trim() ==
        _confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  void openSignupScreen() {
    Navigator.of(context).pushReplacementNamed("signupScreen");
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),

                // Subtitle (Add your subtitle widget here)
                Text(
                  'Welcome! Here you can sign up',
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
                SizedBox(height: 10),

                //  confirm Password TextField
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
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: ' Confirm Password'),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),

                // Sign in Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: signUp,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 45, 183, 77),
                          borderRadius: BorderRadius.circular(12)),
                      child: Center(
                          child: Text(
                        'Sign Up',
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
                      'Already a member? ',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: openSignupScreen,
                      child: Text(
                        'Sign in here',
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
