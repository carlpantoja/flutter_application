import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_db_worker.dart';
import 'contacts_model.dart' show Contact, ContactsModel, contactsModel;
import '../../utils.dart' as utils;

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  Future _deleteContact(BuildContext inContext, Contact inContact) async {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: Text("Apagar contato"),
          content: Text("Deseja excluir ${inContact.name} dos seus contatos?", style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              child: Text("Cancelar"),
              onPressed: () {Navigator.of(inAlertContext).pop();}
            ),

            TextButton(
              child: Text("Apagar"),
              onPressed: () async {
                File avatarFile = File("${utils.docsDir!.path}/${inContact.id.toString()}");

                if(avatarFile.existsSync()) avatarFile.deleteSync();

                await ContactsDBWorker.db.delete(inContact.id!);

                if(!inAlertContext.mounted) return;
                Navigator.of(inContext).pop();

                ScaffoldMessenger.of(inContext).showSnackBar(
                  SnackBar(
                    content: Text("Contato excluído"),
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.red
                  )
                );

                contactsModel.loadData("contacts", ContactsDBWorker.db);
              }
            )
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget? inChild, ContactsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              shape: CircleBorder(),
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
              child: Icon(Icons.add),
              onPressed: () async {
                File avatarFile = File("${utils.docsDir!.path}/avatar");

                if(avatarFile.existsSync()) avatarFile.deleteSync();

                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate("");
                contactsModel.setStackIndex(1);
              }
            ),

            body: contactsModel.entityList.isEmpty ? Center(child: Text("Adicione seu primeiro contato")) : ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Contact contact = contactsModel.entityList[inIndex];
                File avatarFile = File("${utils.docsDir!.path}/${contact.id.toString()}");
                bool avatarFileExists = avatarFile.existsSync();

                return Column(
                  children: [
                    Slidable(
                      startActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            label: "Apagar",
                            icon: Icons.delete,
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            onPressed: (context) => _deleteContact(inContext, contact)
                          )
                        ]
                      ),

                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigoAccent,
                          foregroundColor: Colors.white,
                          backgroundImage: avatarFileExists ? FileImage(avatarFile) : null,
                          child: avatarFileExists ? null : Text(contact.name!.substring(0, 1).toUpperCase())
                        ),
                        title: Text("${contact.name}"),
                        subtitle: contact.phone == null ? null : Text("${contact.phone}"),
                        onTap: () async {
                          File avatarFile = File("${utils.docsDir!.path}/avatar");

                          if(avatarFile.existsSync()) avatarFile.deleteSync();

                          contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id!);

                          if(contactsModel.entityBeingEdited.birthday == null) {contactsModel.setChosenDate("");}
                          else {
                            List dateParts = contactsModel.entityBeingEdited.birthday.split(",");
                            DateTime birthday = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
                            contactsModel.setChosenDate(DateFormat("dd/MM/yyyy", "pt_BR").format(birthday.toLocal()));
                          }

                          contactsModel.setStackIndex(1);
                        }
                      )
                    )
                  ]
                );
              }
            )
          );
        }
      )
    );
  }
}