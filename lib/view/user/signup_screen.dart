import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduationproject/view/widget/colors.dart';
import 'package:graduationproject/view/widget/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool showPassword = false;
  double? height;
  double? width;
  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  String? nameError;
  String? emailError;
  String? passwordError;
  String? generalError;

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              "images/image.png",
              width: width,
              height: height,
              fit: BoxFit.fill,
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              width: width,
              margin: EdgeInsets.only(
                top: height! * .30,
              ),
              padding: const EdgeInsets.all(
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "create new account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Text(
                    "Hello we are glad you have joined our family!!",
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
                      controller: nameTextEditingController,
                      onChanged: (value) {
                        setState(() {
                          if (value.isEmpty) {
                            nameError = "Name is required";
                          } else {
                            nameError = null;
                          }
                        });
                      },
                      decoration: InputDecoration(
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelText: "full name",
                        hintText: "enter your name",
                        errorText: nameError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            31.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
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
                        hintText: "demo@demo.com",
                        errorText: emailError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            31.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      right: 20,
                    ),
                    child: TextField(
                      controller: passwordTextEditingController,
                      obscureText: !showPassword,
                      onChanged: (value) {
                        setState(() {
                          if (value.length < 8) {
                            passwordError = "Password must be at least 8 characters";
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
                          borderRadius: BorderRadius.circular(
                            31.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  CustomButton(
                    text: "Signup",
                    onTap: () async {
                      setState(() {
                        generalError = null;
                      });

                      if (nameError != null || emailError != null || passwordError != null) {
                        return;
                      }

                      try {
                        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: emailTextEditingController.text,
                          password: passwordTextEditingController.text,
                        );

                        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                          'name': nameTextEditingController.text,
                          'email': emailTextEditingController.text,
                          'id': userCredential.user!.uid,
                        });

                        Navigator.of(context).pushReplacementNamed("Login");
                      } on FirebaseAuthException catch (e) {
                        setState(() {
                          if (e.code == 'email-already-in-use') {
                            emailError = "The account already exists for that email.";
                          } else if (e.code == 'invalid-email') {
                            emailError = "The email address is not valid.";
                          } else {
                            generalError = "An error occurred. Please try again.";
                          }
                        });
                      }
                    },
                  ),
                  if (generalError != null)
                    Text(
                      generalError!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  Row(
                    children: [
                      Text(
                        "already have an account",
                        style: TextStyle(
                          color: Color.fromARGB(255, 66, 63, 63),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed("Login");
                        },
                        child: Text(
                          "Login",
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
            )
          ],
        ),
      ),
    );
  }
}
