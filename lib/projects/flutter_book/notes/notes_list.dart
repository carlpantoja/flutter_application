import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notes_db_worker.dart';
import 'notes_model.dart' show Note, NotesModel, notesModel;

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  Future _deleteNote(BuildContext inContext, Note inNote) {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: Text("Apagar nota"),
          content: Text("Deseja excluir ${inNote.title}?", style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {Navigator.of(inAlertContext).pop();}
            ),

            TextButton(
              child: Text("Apagar"),
              onPressed: () async {
                await NotesDBWorker.db.delete(inNote.id!);

                if(!inAlertContext.mounted) return;
                Navigator.of(inAlertContext).pop();

                ScaffoldMessenger.of(inContext).showSnackBar(
                  SnackBar(
                    content: Text("Nota excluída!"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red
                  )
                );

                notesModel.loadData("notes", NotesDBWorker.db);
              }
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext inContext, Widget? inChild, NotesModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              shape: CircleBorder(),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
              onPressed: () {
                notesModel.entityBeingEdited = Note();
                notesModel.setColor("");
                notesModel.setStackIndex(1);
              }
            ),

            body: notesModel.entityList.isEmpty ? Center(child: Text("Crie uma nota")) : ListView.builder(
              itemCount: notesModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Note note = notesModel.entityList[inIndex];
                Color color = Colors.black87;

                switch(note.color) {
                  case "red": color = Colors.red; break;
                  case "green": color = Colors.green; break;
                  case "blue": color = Colors.blue; break;
                  case "orange": color = Colors.orange; break;
                  case "grey": color = Colors.grey; break;
                  case "purple": color = Colors.purple; break;
                }

                return Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Slidable(
                    startActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          label: "Apagar",
                          icon: Icons.delete,
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          onPressed: (context) => _deleteNote(inContext, note)
                        )
                      ]
                    ),

                    child: Card(
                      elevation: 8,
                      color: color,
                      child: ListTile(
                        title: Text("${note.title}", style: TextStyle(color: Colors.white, fontSize: 20)),
                        subtitle: Text("${note.content}", style: TextStyle(color: Colors.white, fontSize: 18)),
                        onTap: () async {
                          notesModel.entityBeingEdited = await NotesDBWorker.db.get(note.id!);
                          notesModel.entityBeingEdited.color ??= notesModel.entityBeingEdited.color = "black";
                          notesModel.setColor(notesModel.entityBeingEdited.color);
                          notesModel.setStackIndex(1);
                        }
                      )
                    )
                  )
                );
              }
            )
          );
        }
      )
    );
  }
}