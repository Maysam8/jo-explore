import 'dart:async';
import 'package:flutter/material.dart';
import 'user/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _dotPosition = 0.0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        _dotPosition += 1; 
        if (_dotPosition > 2) {
          _dotPosition = 0; 
        }
      });
    });
    _navigateToLogin(); 
  }

  void _navigateToLogin() {
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
      
          Image.asset(
            "images/image.png",
            fit: BoxFit.cover,
          ),
          
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/logo.png"), 
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(0),
                  SizedBox(width: 8),
                  _buildDot(1),
                  SizedBox(width: 8),
                  _buildDot(2),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    double opacity = (_dotPosition - index).abs() < 1 ? 1 : 0.2; 
    return Opacity(
      opacity: opacity,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
      ),
    );
  }
}
