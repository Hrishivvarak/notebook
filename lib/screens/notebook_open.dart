import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notebook/screens/create_note.dart';
import 'package:notebook/screens/create_notebook.dart';
import 'package:notebook/screens/home_screen.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:notebook/screens/notesread.dart';

class NotebookOpen extends StatefulWidget {
  final String title ;
  final String notebookid ;
  const NotebookOpen({super.key, required this.title, required this.notebookid});

  @override
  State<NotebookOpen> createState() => _NotebookOpenState();
}

class _NotebookOpenState extends State<NotebookOpen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userid = FirebaseAuth.instance.currentUser!.uid;

  Stream<QuerySnapshot> _allnotes() {
    return _db.collection('users').doc(userid).collection('notebooks').doc(widget.notebookid).collection('notes').orderBy('createdAt').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }, icon: Icon(Icons.home)),
          elevation: 2,
          title: Text(widget.title),
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40,),
              //meow**************************************************************************************


              Center(
                child: Container(
                  height: 500,
                  width: double.infinity,
                  color: Color(0xFFD9D9D9),
                  child: StreamBuilder<QuerySnapshot>(stream: _allnotes(),
                      builder: (context, snapshot)
                      {
                        if(snapshot.connectionState == ConnectionState.waiting)
                        {
                          return Center(child: CircularProgressIndicator(),);
                        }
                        if(!snapshot.hasData || snapshot.data!.docs.isEmpty)
                        {
                          return Center(child: Text("No notes yet."));
                        }
                        var notebooks = snapshot.data!.docs;
                        return SingleChildScrollView(
                          child: Column(
                            children: notebooks.map((doc){
                              var title = doc['name'] ?? 'Untitled';
                              return Slidable(
                                key: ValueKey(doc.id),
                                endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    extentRatio: 0.25,
                                    children: [
                                      SlidableAction(onPressed: (context) async{
                                        await _db
                                            .collection('users')
                                            .doc(userid)
                                            .collection('notebooks')
                                            .doc(widget.notebookid)
                                            .collection('notes')
                                            .doc(doc.id)
                                            .delete();
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title deleted')),);
                                      },
                                        backgroundColor: Colors.blue,
                                        borderRadius: BorderRadius.circular(10),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      )
                                    ]
                                ),
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Notesread(title: title,notesid: doc.id,notebooksid:widget.notebookid)),);
                                  },
                                  child: Container(
                                    height: 55,
                                    width: double.infinity,
                                    margin: EdgeInsets.all(8),
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF000000),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 60 : 20,),
          child: FloatingActionButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateNote(notebookid: widget.notebookid)));
          },
            child: Icon(Icons.add),
          ),
        )
    );
  }
}