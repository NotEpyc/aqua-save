import 'package:aquasave/screens/sidebar_screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:aquasave/theme/theme.dart';
import 'package:aquasave/screens/login_screen/signin_screen.dart';
import 'package:aquasave/widgets/custom_scaffold.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  final FocusNode _passwordFocusNode = FocusNode(); // FocusNode for password field
  final FocusNode _fullNameFocusNode = FocusNode(); // FocusNode for full name field
  final FocusNode _emailFocusNode = FocusNode(); // FocusNode for email field

  String fullName = '';
  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    _fullNameFocusNode.addListener(() {
      setState(() {});
    });

    _emailFocusNode.addListener(() {
      setState(() {});
    });

    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fullNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Sign Up function for Firebase Authentication
  Future<void> signUp() async {
    if (_formSignupKey.currentState!.validate() && agreePersonalData) {
      try {
        // Create user using Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        User? user = userCredential.user;

        if (user != null) {
          // Save user data to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'email': user.email,
            'created_at': FieldValue.serverTimestamp(),
          });

          // Navigate to HomeScreen after successful signup
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = e.message ?? 'An error occurred. Please try again.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } else if (!agreePersonalData) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please agree to the terms and conditions')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(
              height: 10,
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignupKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),

                      // Full Name
                      TextFormField(
                        focusNode: _fullNameFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Full name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Full Name'),
                          labelStyle: TextStyle(
                            color: lightColorScheme.primary,
                          ),
                          hintText: 'Enter Full Name',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _fullNameFocusNode.hasFocus
                                  ? const Color.fromARGB(255, 79, 208, 206)
                                  : Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          fullName = value;
                        },
                      ),

                      const SizedBox(height: 25.0),

                      // Email
                      TextFormField(
                        focusNode: _emailFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Email'),
                          labelStyle: TextStyle(
                            color: lightColorScheme.primary,
                          ),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _emailFocusNode.hasFocus
                                  ? const Color.fromARGB(255, 79, 208, 206)
                                  : Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          email = value;
                        },
                      ),

                      const SizedBox(height: 25.0),

                      // Password
                      TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        focusNode: _passwordFocusNode,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          labelStyle: TextStyle(
                            color: lightColorScheme.primary,
                          ),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _passwordFocusNode.hasFocus
                                  ? const Color.fromARGB(255, 79, 208, 206)
                                  : Colors.black12,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: (value) {
                          password = value;
                        },
                      ),

                      const SizedBox(height: 25.0),

                      // Agree to terms
                      Row(
                        children: [
                          Checkbox(
                            value: agreePersonalData,
                            onChanged: (bool? value) {
                              setState(() {
                                agreePersonalData = value!;
                              });
                            },
                            activeColor: lightColorScheme.primary,
                          ),
                          const Text(
                            'I agree to the ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: lightColorScheme.primary,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25.0),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: lightColorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Sign Up'),
                        ),
                      ),

                      const SizedBox(height: 60.0),

                      // Already have an account
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (e) => const SignInScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
