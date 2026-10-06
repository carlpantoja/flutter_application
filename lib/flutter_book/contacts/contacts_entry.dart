import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_db_worker.dart';
import 'contacts_model.dart' show ContactsModel, contactsModel;
import '../../utils.dart' as utils;

class ContactsEntry extends StatelessWidget {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry({super.key}) {
    _nameEditingController.addListener(() {contactsModel.entityBeingEdited.name = _nameEditingController.text;});
    _phoneEditingController.addListener(() {contactsModel.entityBeingEdited.phone = _phoneEditingController.text;});
    _emailEditingController.addListener(() {contactsModel.entityBeingEdited.email = _emailEditingController.text;});
  }

  void _save(BuildContext inContext, ContactsModel inModel) async {
    dynamic id;

    if(!_formKey.currentState!.validate()) return;

    if(inModel.entityBeingEdited.id == null) {id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);}
    else {
      id = contactsModel.entityBeingEdited.id;
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }

    File avatarFile = File("${utils.docsDir!.path}/avatar");

    if(avatarFile.existsSync()) avatarFile.renameSync("${utils.docsDir!.path}/${id.toString()}");

    contactsModel.loadData("contacts", ContactsDBWorker.db);

    inModel.setStackIndex(0);

    if(!inContext.mounted) return;

    ScaffoldMessenger.of(inContext).showSnackBar(
      SnackBar(
        content: Text("Contato salvo"),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green
      )
    );
  }

  Future _selectAvatar(BuildContext inContext) {
    return showDialog(
      context: inContext,
      builder: (BuildContext inDialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                GestureDetector(
                  child: Text("Tirar foto", style: TextStyle(fontSize: 18)),
                  onTap: () async {
                    ImagePicker picker = ImagePicker();
                    XFile? xCameraImage = await picker.pickImage(source: ImageSource.camera);

                    if(xCameraImage != null) {
                      File cameraImage = File(xCameraImage.path);
                      cameraImage.copySync("${utils.docsDir!.path}/avatar");

                      contactsModel.triggerRebuild();
                    }

                    if(!inDialogContext.mounted) return;
                    Navigator.of(inDialogContext).pop();
                  }
                ),

                Padding(padding: EdgeInsets.all(10)),

                GestureDetector(
                  child: Text("Galeria", style: TextStyle(fontSize: 18)),
                  onTap: () async {
                    ImagePicker picker = ImagePicker();
                    XFile? xGalleryImage = await picker.pickImage(source: ImageSource.gallery);

                    if(xGalleryImage != null) {
                      File galleryImage = File(xGalleryImage.path);
                      galleryImage.copySync("${utils.docsDir!.path}/avatar");

                      contactsModel.triggerRebuild();
                    }

                    if(!inDialogContext.mounted) return;
                    Navigator.of(inDialogContext).pop();
                  }
                )
              ]
            )
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if(contactsModel.entityBeingEdited != null) {
      if(contactsModel.entityBeingEdited.name != null) _nameEditingController.text = contactsModel.entityBeingEdited.name;
      if(contactsModel.entityBeingEdited.phone != null) _phoneEditingController.text = contactsModel.entityBeingEdited.phone;
      if(contactsModel.entityBeingEdited.email != null) _emailEditingController.text = contactsModel.entityBeingEdited.email;
    }

    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget? inChild, ContactsModel inModel) {
          File avatarFile = File("${utils.docsDir!.path}/avatar");

          if(avatarFile.existsSync() == false) {
            if(inModel.entityBeingEdited != null && inModel.entityBeingEdited.id != null) avatarFile = File("${utils.docsDir!.path}/${inModel.entityBeingEdited.id.toString()}");
          }

          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    child: Text("Cancelar", style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      File avatarFile = File("${utils.docsDir!.path}/avatar");

                      if(avatarFile.existsSync()) avatarFile.deleteSync();

                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    }
                  ),

                  Spacer(),

                  TextButton(
                    child: Text("Salvar", style: TextStyle(color: Colors.black)),
                    onPressed: () {_save(inContext, contactsModel);}
                  )
                ]
              )
            ),

            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    title: Center(
                      child: CircleAvatar(
                        backgroundImage: avatarFile.existsSync() ? FileImage(avatarFile) : null,
                        radius: 100,
                        child: avatarFile.existsSync() ? Opacity(
                          opacity: 0,
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: Text(""),
                              onPressed: () => _selectAvatar(inContext)
                            )
                          )
                        ) : IconButton(
                          icon: const Icon(Icons.person, size: 150),
                          color: Colors.black26,
                          onPressed: () => _selectAvatar(inContext)
                        )
                      )
                    )
                  ),

                  ListTile(
                    leading: Icon(Icons.person),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Nome"),
                      controller: _nameEditingController,
                      validator: (String? value) {
                        if(value!.isEmpty) return "Insira um nome";
                        
                        return null;
                      }
                    )
                  ),

                  ListTile(
                    leading: Icon(Icons.phone),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Telefone"),
                      controller: _phoneEditingController,
                      keyboardType: TextInputType.phone
                    )
                  ),

                  ListTile(
                    leading: Icon(Icons.email),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Email"),
                      controller: _emailEditingController,
                      keyboardType: TextInputType.emailAddress
                    )
                  ),

                  ListTile(
                    leading: Icon(Icons.cake),
                    title: Text("Aniversário"),
                    subtitle: Text(contactsModel.chosenDate == null ? "" : contactsModel.chosenDate!),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String? chosenDate = await utils.selectDate(inContext, contactsModel, contactsModel.entityBeingEdited.birthday);
                        if(chosenDate != null) contactsModel.entityBeingEdited.birthday = chosenDate;
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