import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todoapp/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  //text controller
  final TextEditingController textController = TextEditingController();

  void openBox({String? docId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          //button to save
          ElevatedButton(
            onPressed: () {
              if (docId == null) {
                firestoreService.addNote(textController.text);
              } else {
                firestoreService.updateNote(docId, textController.text);
              }

              //clear text after save
              textController.clear();

              //close the box
              Navigator.pop(context);
            },
            child: (docId != null) ? Text('update') : Text("Add"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("ToDo App")),
        elevation: 100,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          //get the docs if present
          if (snapshot.hasData) {
            List<DocumentSnapshot> noteList = snapshot.data!.docs;

            //display the list
            return ListView.builder(
              itemCount: noteList.length,
              itemBuilder: (context, index) {
                //get individual docs
                DocumentSnapshot document = noteList[index];
                String docId = document.id;

                //get notes from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;

                String noteText = data['note'];

                //display list tile
                return ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //update
                      IconButton(
                        onPressed: () => openBox(docId: docId),
                        icon: const Icon(Icons.arrow_circle_up),
                      ),
                      //delete
                      IconButton(
                        onPressed: () => firestoreService.deleteNode(docId),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No Notes found ..."));
          }
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomePage(),
  ));
}
