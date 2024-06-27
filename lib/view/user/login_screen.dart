import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:graduationproject/view/widget/colors.dart';
import 'package:graduationproject/view/widget/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;
  double? height;
  double? width;
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  String? emailError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: width,
              height: height! * .3,
              child: Stack(
                children: [
                  Image.asset(
                    "images/image.png",
                    width: width,
                    height: height! * .3,
                    fit: BoxFit.fill,
                  ),
                  Center(
                    child: Image.asset(
                      "images/logo.png",
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: width,
              height: height! * .71,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "login",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Text(
                    "welcome!! log in with your email",
                    style: TextStyle(
                      color: Color.fromARGB(255, 66, 63, 63),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            emailError = "Email is required";
                          } else {
                            emailError = null;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "email",
                        hintText: "example@example.com",
                        errorText: emailError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(31.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 22,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    child: TextField(
                      controller: passwordTextEditingController,
                      obscureText: !showPassword,
                      onChanged: (value) {
                        setState(() {
                          if (value.length < 8) {
                            passwordError =
                                "Password must be at least 8 characters";
                          } else {
                            passwordError = null;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                        hintText: "enter your password",
                        errorText: passwordError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(31.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    text: "login",
                    onTap: () async {
                      if (emailError != null || passwordError != null) {
                        return;
                      }

                      try {
                        final credential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                          email: emailTextEditingController.text,
                          password: passwordTextEditingController.text,
                        );

                        final User? user = credential.user;
                        final userId = user?.uid;

                        final userData = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get();
                        final userEmail = userData.get('email');
                        final userName = userData.get('name');

                        print('User Email: $userEmail');
                        print('User Name: $userName');

                        Navigator.of(context).pushReplacementNamed("Homepage");
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'user-not-found') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('No user found for that email.'),
                            ),
                          );
                        } else if (e.code == 'wrong-password') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Wrong password provided for that user.'),
                            ),
                          );
                        } else {
                          print('Error occurred: ${e.message}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('An error occurred: ${e.message}'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "dont have an account??",
                        style: TextStyle(
                          color: Color.fromARGB(255, 66, 63, 63),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed("signup");
                        },
                        child: Text(
                          "register now",
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
