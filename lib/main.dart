import 'package:flutter/material.dart';
import 'package:mon/api/sheets/data_sheets_api.dart';
import 'package:mon/page/create.dart';
import 'package:mon/page/modify.dart';
import 'package:mon/page/setting.dart';
import 'package:mon/page/view.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
  await Hive.openBox('offline_data');
  await DataApi.init();
  await DataApi.syncOfflineData();
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
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    Connectivity().onConnectivityChanged.listen((status) async {
      print('[Connectivity] Changed to: $status');
      if (status != ConnectivityResult.none) {
        print('[Connectivity] Reconnected. Trying to sync...');
        await DataApi.init(); // Ensure sheet is ready
        await DataApi.syncOfflineData(); // Try syncing
      }
    });
  }

  int _selectedIndex = 0;

  // List of pages for navigation
  final List<Widget> _pages = [
    const CreateSheetsPage(),
    const ModifySheetsPage(),
    SettingsPage(),
    ViewAllPage()
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
            icon: Icon(Icons.add),
            label: 'Create Sheets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Modify Sheets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'View',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
