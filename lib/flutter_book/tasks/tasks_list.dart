import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'tasks_db_worker.dart';
import 'tasks_model.dart' show Task, TasksModel, tasksModel;

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  Future _deleteTask(BuildContext inContext, Task inTask) {
    return showDialog(
      context: inContext,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: Text("Apagar tarefa"),
          content: Text("Deseja excluir ${inTask.description}?", style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {Navigator.of(inAlertContext).pop();}
            ),

            TextButton(
              child: Text("Apagar"),
              onPressed: () async {
                await TasksDBWorker.db.delete(inTask.id!);

                if(!inAlertContext.mounted) return;
                Navigator.of(inAlertContext).pop();

                ScaffoldMessenger.of(inContext).showSnackBar(
                  SnackBar(
                    content: Text("Tarefa excluída!"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red
                  )
                );

                tasksModel.loadData("tasks", TasksDBWorker.db);
              }
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget? inChild, TasksModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              shape: CircleBorder(),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
              onPressed: () {
                tasksModel.entityBeingEdited = Task();
                tasksModel.setChosenDate("");
                tasksModel.setStackIndex(1);
              }
            ),

            body: tasksModel.entityList.isEmpty ? Center(child: Text("Crie uma tarefa")) : ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
              itemCount: tasksModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Task task = tasksModel.entityList[inIndex];
                String sDueDate = "";

                if(task.dueDate != null) {
                  List dateParts = task.dueDate!.split(",");
                  DateTime dueDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
                  sDueDate = DateFormat("dd/MM/yyyy", "pt_BR").format(dueDate.toLocal());
                }

                return Slidable(
                  startActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        label: "Apagar",
                        icon: Icons.delete,
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        onPressed: (context) => _deleteTask(inContext, task)
                      )
                    ]
                  ),

                  child: Card(
                    elevation: 8,
                    color: Colors.grey[200],
                    child: ListTile(
                      leading: Checkbox(
                        shape: CircleBorder(),
                        side: BorderSide(style: BorderStyle.none),
                        fillColor: WidgetStatePropertyAll(Colors.white),
                        checkColor: Colors.lightBlue,
                        value: task.completed == "true" ? true : false,
                        onChanged: (inValue) async {
                          task.completed = inValue.toString();
                          await TasksDBWorker.db.update(task);
                          tasksModel.loadData("tasks", TasksDBWorker.db);
                        }
                      ),
                      title: Text("${task.description}", style: task.completed == "true" ? TextStyle(color: Theme.of(inContext).disabledColor, decoration: TextDecoration.lineThrough, fontSize: 18) : TextStyle(color: Colors.black, fontSize: 22)),
                      subtitle: task.dueDate == null ? null : Text(sDueDate, style: task.completed == "true" ? TextStyle(color: Theme.of(inContext).disabledColor, decoration: TextDecoration.lineThrough, fontSize: 18) : TextStyle(color: Colors.black, fontSize: 22)),
                      onTap: () async {
                        if(task.completed == "true") return;

                        tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id!);

                        if(tasksModel.entityBeingEdited.dueDate == null) {tasksModel.setChosenDate("");}
                        else {tasksModel.setChosenDate(sDueDate);}

                        tasksModel.setStackIndex(1);
                      }
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