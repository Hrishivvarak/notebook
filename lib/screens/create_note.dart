import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notebook/screens/home_screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class CreateNote extends StatefulWidget {
  final String notebookid;

  const CreateNote({super.key, required this.notebookid});

  @override
  State<CreateNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateNote> {
  final quill.QuillController _quillController = quill.QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _createnote() async {
    try {
      final jsoncontent = _quillController.document.toDelta().toJson();
      await _db
          .collection('users')
          .doc(userid)
          .collection('notebooks')
          .doc(widget.notebookid)
          .collection('notes')
          .add({
        'name': _titleController.text.trim(),
        'note content': jsoncontent,
        'createdAt': Timestamp.now(),
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseFirestore catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note creation failed")),
      );
    }
  }

  void _toggleAttribute(quill.Attribute attribute) {
    final currentSelection = _quillController.getSelectionStyle();
    if (currentSelection.containsKey(attribute.key)) {
      // Remove attribute
      _quillController.formatSelection(
        quill.Attribute.clone(attribute, null),
      );
    } else {
      // Apply attribute
      _quillController.formatSelection(attribute);
    }
  }

  void _pickTextColor() {
    Color pickerColor = Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a text color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Select'),
              onPressed: () {
                Navigator.of(context).pop();
                String hexColor =
                    '#${pickerColor.value.toRadixString(16).substring(2)}';

                final currentSelection = _quillController.getSelectionStyle();
                if (currentSelection.attributes.containsKey('color') &&
                    currentSelection.attributes['color']!.value == hexColor) {
                  // Remove color
                  _quillController.formatSelection(
                    quill.Attribute.clone(quill.Attribute.color, null),
                  );
                } else {
                  // Apply color
                  _quillController.formatSelection(
                    quill.Attribute.fromKeyValue('color', hexColor),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          icon: const Icon(Icons.home),
        ),
        elevation: 2,
        title: const Text("Add Notes"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Container(
                height: 3.0,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 4.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF000000),
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(2),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Formatting toolbar
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFD9D9D9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Center(
                                child: IconButton(
                                  onPressed: () =>
                                      _toggleAttribute(quill.Attribute.bold),
                                  icon: const Icon(Icons.format_bold),
                                ),
                              ),
                            ),
                            Container(
                                color: const Color(0xFFA0A0A0),
                                height: 30,
                                width: 1),
                            Expanded(
                              child: Center(
                                child: IconButton(
                                  onPressed: () =>
                                      _toggleAttribute(quill.Attribute.italic),
                                  icon: const Icon(Icons.format_italic),
                                ),
                              ),
                            ),
                            Container(
                                color: const Color(0xFFA0A0A0),
                                height: 30,
                                width: 1),
                            Expanded(
                              child: Center(
                                child: IconButton(
                                  onPressed: () =>
                                      _toggleAttribute(quill.Attribute.underline),
                                  icon: const Icon(Icons.format_underline),
                                ),
                              ),
                            ),
                            Container(
                                color: const Color(0xFFA0A0A0),
                                height: 30,
                                width: 1),
                            Center(
                              child: IconButton(
                                onPressed: _pickTextColor,
                                icon: const Icon(Icons.color_lens),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Title box
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: "  Title",
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description Box
                      Container(
                        width: double.infinity,
                        height: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFD9D9D9),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: quill.QuillEditor.basic(
                            controller: _quillController,
                            //readOnly: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Save Button
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: const Color(0xFFFFFFFF),
                      ),
                      onPressed: _createnote,
                      child: const Icon(
                        Icons.add,
                        size: 50,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
