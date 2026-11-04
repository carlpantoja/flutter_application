import 'package:flutter/material.dart';
import 'appointments/appointments.dart';
import 'contacts/contacts.dart';
import 'notes/notes.dart';
import 'tasks/tasks.dart';

class FlutterBook extends StatefulWidget {
  const FlutterBook({super.key});

  @override
  State<FlutterBook> createState() => _FlutterBookState();
}

class _FlutterBookState extends State<FlutterBook> {
  int _currentPageIndex = 0;

  void _onItemTapped(int index) {setState(() {_currentPageIndex = index;});}

  static final List<Widget> _widgetList = <Widget> [Appointments(), Contacts(), Notes(), Tasks()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[100],
        title: Text("Flutter Book")
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Agenda"),
          BottomNavigationBarItem(icon: Icon(Icons.contacts_sharp), label: "Contatos"),
          BottomNavigationBarItem(icon: Icon(Icons.note_alt), label: "Notas"),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: "Tarefas")
        ],
        currentIndex: _currentPageIndex,
        unselectedItemColor: Colors.black,
        selectedItemColor: Colors.blue,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped
      ),

      body: _widgetList.elementAt(_currentPageIndex)
    );
  }
}