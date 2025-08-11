import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notebook/screens/home_screen.dart';
import 'package:notebook/screens/signup.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signin() async{
    try{
            await FirebaseAuth.instance.signInWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim()
            );
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    }
    on FirebaseAuthException catch(e)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Sign in failed")),
      );
    }
  }

  @override
  void initState()
  {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null)
    {
      WidgetsBinding.instance.addPostFrameCallback((_){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(

            child: Column(
              children: [
                Text(
                  "Signin.",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 20,),
                Container(
                  height: 60,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                    controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "Email",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                SizedBox(height: 20,),

                Container(
                  height: 60,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: _passwordController,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                SizedBox(height: 20,),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF000000),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)
                          )
                      ),
                      onPressed: _signin ,
                      child: Text(
                        "SIGN IN",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFFFFFFFF),
                            fontWeight: FontWeight.w600
                        ),
                      )
                  ),
                ),
                SizedBox(height: 10,),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
                  },
                  child: Text(
                    "Dont have an account? Signup",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
