import 'package:flutter/material.dart';
import 'package:notebook/screens/create_note.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notebook/screens/home_screen.dart';
import 'package:notebook/screens/notebook_open.dart';

class CreateNotebook extends StatefulWidget {
  const CreateNotebook({super.key});

  @override
  State<CreateNotebook> createState() => _CreateNotebookState();
}

class _CreateNotebookState extends State<CreateNotebook> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _discriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  Future<void> _createNotebook() async
  {
    try {
      await _db.collection('users').doc(userid).collection('notebooks').add({
        'name':_titleController.text.trim(),
        'Description': _discriptionController.text.trim(),
        'createdAt':Timestamp.now(),
      });
      
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text(e.message ?? "Notebook Created Successfully!"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
        }, icon: Icon(Icons.home)),
        elevation: 2,
        title: Text("Add Book"),
        bottom: PreferredSize(preferredSize: Size.fromHeight(4.0),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Container(
                  height: 3.0,
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 4.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF000000),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
            )),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            height: 500,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: double.infinity,
                  height: 60,
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: "  Title",
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFFD9D9D9),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: TextField(
                      controller: _discriptionController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Discription',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  width: 130,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFD9D9D9),
                        elevation: 1,

                      ),
                      onPressed: _createNotebook,
                      child: Text(
                          "Create",
                        style: TextStyle(
                         fontSize: 18,
                          color: Color(0xFF000000),
                        ),
                      )
                  ),
                )
              ],
            ),

          ),
        ),
      ),
    );
  }
}
