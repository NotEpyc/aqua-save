import 'package:aquasave/screens/sidebar_screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aquasave/widgets/custom_scaffold.dart';
import 'package:aquasave/theme/theme.dart';
import 'package:aquasave/screens/login_screen/signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode(); // FocusNode for password field
  final FocusNode _emailFocusNode = FocusNode(); // FocusNode for email field
  bool rememberPassword = true;

  @override
  void initState() {
    
    super.initState();
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    super.initState();
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  // Sign In function with logging for debugging
Future<void> _signIn() async {
  print("Starting sign-in process");

  if (_formSignInKey.currentState!.validate() && rememberPassword) {
    try {
      print("Form validated, attempting sign-in...");
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Attempt to sign in using Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print("Sign-in successful, navigating to HomeScreen...");

      // Close loading indicator
      Navigator.pop(context);

      // Navigate to HomeScreen after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException errors
      print("FirebaseAuthException caught: ${e.code}");
      Navigator.pop(context); // Close loading indicator

      String errorMessage = 'An error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password.';
      }

      print("Error message: $errorMessage");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // General error handling
      print("General error caught: ${e.toString()}");
      Navigator.pop(context); // Close loading indicator

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  } else if (!rememberPassword) {
    print("Remember password not checked.");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please agree to the processing of personal data')),
    );
  } else {
    print("Form validation failed.");
  }
}


  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
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
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: lightColorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      
                      // Email
                      TextFormField(
                        controller: _emailController,
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
                            color: lightColorScheme.primary, // Label color
                          ),
                          hintText: 'Enter Email',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Change this to desired color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _emailFocusNode.hasFocus
                                  ? const Color.fromARGB(255, 79, 208, 206) // Change color when focused
                                  : Colors.black12, // Default color when not focused
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // Password
                      TextFormField(
                        obscureText: true,
                        obscuringCharacter: '*',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode, // Attach the FocusNode here
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          label: const Text('Password'),
                          labelStyle: TextStyle(
                            color: lightColorScheme.primary, // Label color
                          ),
                          hintText: 'Enter Password',
                          hintStyle: const TextStyle(
                            color: Colors.black26,
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.black12, // Default border color
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: _passwordFocusNode.hasFocus
                                  ? const Color.fromARGB(255, 79, 208, 206) // Change color when focused
                                  : Colors.black12, // Default color when not focused
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor: lightColorScheme.primary,
                              ),
                              const Text(
                                'Remember me',
                                style: TextStyle(color: Colors.black45),
                              ),
                            ],
                          ),
                          GestureDetector(
                            child: Text(
                              'Forget password?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: lightColorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25.0),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _signIn,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: lightColorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 25.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: Colors.black45),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (e) => const SignUpScreen()),
                              );
                            },
                            child: Text(
                              'Sign up',
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
