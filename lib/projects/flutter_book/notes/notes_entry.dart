import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notes_db_worker.dart';
import 'notes_model.dart' show NotesModel, notesModel;

class NotesEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry({super.key}) {
    _titleEditingController.addListener(() {notesModel.entityBeingEdited.title = _titleEditingController.text;});
    _contentEditingController.addListener(() {notesModel.entityBeingEdited.content = _contentEditingController.text;});
  }

  void _save(BuildContext inContext, NotesModel inModel) async {
    if(!_formKey.currentState!.validate()) return;

    if(inModel.entityBeingEdited.id == null) {await NotesDBWorker.db.create(notesModel.entityBeingEdited);}
    else {await NotesDBWorker.db.update(notesModel.entityBeingEdited);}

    notesModel.loadData("notes", NotesDBWorker.db);

    inModel.setStackIndex(0);

    if(!inContext.mounted) return;

    ScaffoldMessenger.of(inContext).showSnackBar(
      SnackBar(
        content: Text("Nota salva"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if(notesModel.entityBeingEdited != null) {
      if(notesModel.entityBeingEdited.title != null) _titleEditingController.text = notesModel.entityBeingEdited.title;
      if(notesModel.entityBeingEdited.content != null) _contentEditingController.text = notesModel.entityBeingEdited.content;
    }

    return ScopedModel<NotesModel>(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext inContext, Widget? inChild, NotesModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    child: Text("Cancelar", style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    }
                  ),

                  Spacer(),

                  TextButton(
                    child: Text("Salvar", style: TextStyle(color: Colors.black)),
                    onPressed: () {_save(inContext, notesModel);}
                  )
                ]
              )
            ),

            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.title),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Título"),
                      controller: _titleEditingController,
                      validator: (String? value) {
                        if(value!.isEmpty) return "Coloque um título";

                        return null;
                      }
                    )
                  ),

                  ListTile(
                    leading: Icon(Icons.content_paste),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Conteúdo"),
                      controller: _contentEditingController,
                      validator: (String? value) {
                        if(value!.isEmpty) return "Insira um conteúdo";

                        return null;
                      }
                    )
                  ),

                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Row(
                      children: [
                        GestureDetector(
                          child: Container(decoration: ShapeDecoration(shape: Border.all(width: 18, color: Colors.red) + Border.all(width: 6, color: notesModel.color == "red" ? Colors.red : Theme.of(inContext).canvasColor))),
                          onTap: () {
                            notesModel.entityBeingEdited.color = "red";
                            notesModel.setColor("red");
                          }
                        ),

                        Spacer(),

                        GestureDetector(
                          child: Container(decoration: ShapeDecoration(shape: Border.all(width: 18, color: Colors.green) + Border.all(width: 6, color: notesModel.color == "green" ? Colors.green : Theme.of(inContext).canvasColor))),
                          onTap: () {
                            notesModel.entityBeingEdited.color = "green";
                            notesModel.setColor("green");
                          }
                        ),

                        Spacer(),

                        GestureDetector(
                          child: Container(decoration: ShapeDecoration(shape: Border.all(width: 18, color: Colors.blue) + Border.all(width: 6, color: notesModel.color == "blue" ? Colors.blue : Theme.of(inContext).canvasColor))),
                          onTap: () {
                            notesModel.entityBeingEdited.color = "blue";
                            notesModel.setColor("blue");
                          }
                        ),

                        Spacer(),

                        GestureDetector(
                          child: Container(decoration: ShapeDecoration(shape: Border.all(width: 18, color: Colors.orange) + Border.all(width: 6, color: notesModel.color == "orange" ? Colors.orange : Theme.of(inContext).canvasColor))),
                          onTap: () {
                            notesModel.entityBeingEdited.color = "orange";
                            notesModel.setColor("orange");
                          }
                        ),

                        Spacer(),

                        GestureDetector(
                          child: Container(decoration: ShapeDecoration(shape: Border.all(width: 18, color: Colors.grey) + Border.all(width: 6, color: notesModel.color == "grey" ? Colors.grey : Theme.of(inContext).canvasColor))),
                          onTap: () {
                            notesModel.entityBeingEdited.color = "grey";
                            notesModel.setColor("grey");
                          }
                        ),

                        Spacer(),

                        GestureDetector(
                          child: Container(decoration: ShapeDecoration(shape: Border.all(width: 18, color: Colors.purple) + Border.all(width: 6, color: notesModel.color == "purple" ? Colors.purple : Theme.of(inContext).canvasColor))),
                          onTap: () {
                            notesModel.entityBeingEdited.color = "purple";
                            notesModel.setColor("purple");
                          }
                        )
                      ]
                    )
                  )
                ]
              )
            )
          );
        }
      )
    );
  }
}