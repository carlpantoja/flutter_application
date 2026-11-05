import 'package:flutter/material.dart';
import '../projects/flutter_book/flutter_book.dart';

class AppList extends StatelessWidget {
  const AppList({super.key});

  static final List _appList = [
    {
      "app": FlutterBook(),
      "title": "Flutter Book",
      "icon": Icon(Icons.book_rounded),
      "color": Color.fromARGB(255, 96, 125, 139)
    }
  ];
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _appList.length,
      itemBuilder: (BuildContext inBuildContext, int inIndex) {
        return Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Card(
            elevation: 8,
            color: _appList[inIndex]["color"],
            child: ListTile(
              leading: _appList[inIndex]["icon"],
              iconColor: Colors.white,
              title: Text("${_appList[inIndex]["title"]}", style: TextStyle(color: Colors.white)),
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => _appList[inIndex]["app"]));}
            )
          )
        );
      }
    );
  }
}