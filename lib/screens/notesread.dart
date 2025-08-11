import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/quill_delta.dart';
import 'package:notebook/screens/home_screen.dart';

class Notesread extends StatefulWidget {
  final String title;
  final String notesid;
  final String notebooksid;

  const Notesread({
    super.key,
    required this.title,
    required this.notesid,
    required this.notebooksid,
  });

  @override
  State<Notesread> createState() => _NotesreadState();
}

class _NotesreadState extends State<Notesread> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userid = FirebaseAuth.instance.currentUser!.uid;

  quill.QuillController? _quillController;
  bool _isLoading = true;

  Future<void> _loadData() async {
    try {
      DocumentSnapshot documentSnapshot = await _db
          .collection('users')
          .doc(userid)
          .collection('notebooks')
          .doc(widget.notebooksid)
          .collection('notes')
          .doc(widget.notesid)
          .get();

      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        final content = data['note content'];

        setState(() {
          _quillController = quill.QuillController(
            document: quill.Document.fromDelta(
              Delta.fromJson(content),
            ),
            selection: const TextSelection.collapsed(offset: 0),
          );
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading note: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNote() async {
    if (_quillController == null) return;

    try {
      final delta = _quillController!.document.toDelta();
      await _db
          .collection('users')
          .doc(userid)
          .collection('notebooks')
          .doc(widget.notebooksid)
          .collection('notes')
          .doc(widget.notesid)
          .update({
        'note content': delta.toJson(),
        'last_updated': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated successfully')),
      );
    } catch (e) {
      debugPrint("Error updating note: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating note: $e')),
      );
    }
  }

  void _toggleAttribute(quill.Attribute attribute) {
    final currentSelection = _quillController!.getSelectionStyle();
    if (currentSelection.containsKey(attribute.key)) {
      // Remove attribute
      _quillController!.formatSelection(quill.Attribute.clone(attribute, null));
    } else {
      // Apply attribute
      _quillController!.formatSelection(attribute);
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
                final currentSelection = _quillController!.getSelectionStyle();
                if (currentSelection.attributes.containsKey('color') &&
                    currentSelection.attributes['color']!.value == hexColor) {
                  // Remove color
                  _quillController!.formatSelection(
                      quill.Attribute.clone(quill.Attribute.color, null));
                } else {
                  // Apply color
                  _quillController!.formatSelection(
                      quill.Attribute.fromKeyValue('color', hexColor));
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _quillController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
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
        title: Text(widget.title),
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            alignment: Alignment.bottomCenter,
            margin: const EdgeInsets.only(bottom: 4.0),
            height: 3.0,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
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
                        onPressed: () {
                          _toggleAttribute(quill.Attribute.bold);
                        },
                        icon: const Icon(Icons.format_bold),
                      ),
                    ),
                  ),
                  Container(color: const Color(0xFFA0A0A0), height: 30, width: 1),
                  Expanded(
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          _toggleAttribute(quill.Attribute.italic);
                        },
                        icon: const Icon(Icons.format_italic),
                      ),
                    ),
                  ),
                  Container(color: const Color(0xFFA0A0A0), height: 30, width: 1),
                  Expanded(
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          _toggleAttribute(quill.Attribute.underline);
                        },
                        icon: const Icon(Icons.format_underline),
                      ),
                    ),
                  ),
                  Container(color: const Color(0xFFA0A0A0), height: 30, width: 1),
                  Center(
                    child: IconButton(
                      onPressed: _pickTextColor,
                      icon: const Icon(Icons.color_lens),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0xFFD9D9D9),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: quill.QuillEditor.basic(
                    controller: _quillController!,
                    //readOnly: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _updateNote,
        child: const Icon(Icons.edit),
      ),
    );
  }
}
