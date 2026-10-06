import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'tasks_db_worker.dart';
import 'tasks_model.dart' show TasksModel, tasksModel;
import '../../utils.dart' as utils;

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry({super.key}) {
    _descriptionEditingController.addListener(() {tasksModel.entityBeingEdited.description = _descriptionEditingController.text;});
  }

  void _save(BuildContext inContext, TasksModel inModel) async {
    if(!_formKey.currentState!.validate()) return;

    if(inModel.entityBeingEdited.id == null) {await TasksDBWorker.db.create(tasksModel.entityBeingEdited);}
    else {await TasksDBWorker.db.update(tasksModel.entityBeingEdited);}

    tasksModel.loadData("tasks", TasksDBWorker.db);

    inModel.setStackIndex(0);

    if(!inContext.mounted) return;
    ScaffoldMessenger.of(inContext).showSnackBar(
      SnackBar(
        content: Text("Tarefa salva"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    if(tasksModel.entityBeingEdited != null) {
      if(tasksModel.entityBeingEdited.description != null) _descriptionEditingController.text = tasksModel.entityBeingEdited.description;
    }

    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget? inChild, TasksModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
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
                    onPressed: () {_save(inContext, tasksModel);}
                  )
                ]
              )
            ),

            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: "Conteúdo"),
                      controller: _descriptionEditingController,
                      validator: (String? value) {
                        if(value!.isEmpty) return "Escreva algo";

                        return null;
                      }
                    )
                  ),

                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Definir data"),
                    subtitle: Text(tasksModel.chosenDate == null ? "" : tasksModel.chosenDate!),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String? chosenDate = await utils.selectDate(inContext, tasksModel, tasksModel.entityBeingEdited.dueDate);
                        if(chosenDate != null) tasksModel.entityBeingEdited.dueDate = chosenDate;
                      }
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