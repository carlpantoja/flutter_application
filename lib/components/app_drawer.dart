import 'package:flutter/material.dart';
import '../projects/flutter_book/flutter_book.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 100.0,
            child: DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(fontSize: 22, color: Colors.white))
            )
          ),

          ListTile(
            title: Text("Flutter Book"),
            onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => FlutterBook()));}
          )
        ]
      )
    );
  }
}