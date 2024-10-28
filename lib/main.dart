import 'package:flutter/material.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';
import 'package:mon/page/create.dart';
import 'package:mon/page/modify.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataApi.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; 

  // List of pages for navigation
  final List<Widget> _pages = [
    ModifySheetsPage(),
    CreateSheetsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], 
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Modify Sheets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Sheets',
          ),
        ],
        currentIndex: _selectedIndex, 
        onTap: _onItemTapped, 
      ),
    );
  }
}
