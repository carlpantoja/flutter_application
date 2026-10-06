import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'flutter_book/flutter_book.dart';
import 'utils.dart' as utils;

void main() async {
  start() async {
    initializeDateFormatting("pt_BR", null).then((_) {runApp(const MyApp());});

    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
  }

  start();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: "Flutter App"),
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [Locale("pt")]
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 100.0,
              child: DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Text("Menu", style: TextStyle(fontSize: 22, color: Colors.white))
              )
            ),

            ListTile(
              title: const Text("Flutter Book"),
              onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => FlutterBook()));}
            )
          ]
        )
      ),
      
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Veja aplicações mobile feitas com Flutter", style: TextStyle(fontSize: 18)),
            FlutterLogo()
          ]
        )
      )
    );
  }
}
