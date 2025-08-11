import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notebook/screens/signin.dart';


class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _signup() async{
    try{

            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim(),
            );

            await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({'email':_emailController.text.trim(),'createdAt': Timestamp.now()});
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Signin()));
    }
    on FirebaseAuthException catch(e)
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Sign up failed")),
      );
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
                        "Signup.",
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
                          onPressed: _signup,
                      child: Text(
                          "SIGN UP",
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Signin()));
                      },
                      child: Text(
                        "Already have an account? Signin",

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
