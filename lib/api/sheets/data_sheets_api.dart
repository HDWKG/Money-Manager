import 'package:gsheets/gsheets.dart';
import 'package:mon/api/sheets/config.dart';
import 'package:mon/model/user.dart';

class DataApi {
  static String _activeTab = 'Data';
  static String? activeTab;
   static final _credetials = Config.credentials;
  static final _spreadsheetId = Config.spreadsheetId; 
  static final _gsheets = GSheets(_credetials);
  static Worksheet? _userSheet;

  static Future<void> setActiveTab(String tabName) async {
    _activeTab = tabName;
    await _initializeUserSheet();
  }

  static Future<void> _initializeUserSheet() async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      _userSheet = await _getWorkSheet(spreadsheet, title: _activeTab);
      final firstRow = UserFields.getFields();
      _userSheet!.values.insertRows(1, [firstRow]);
    } catch (e) {
      print('Init Error: $e');
    }
  }

  static Future<void> init() async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      _userSheet = await _getWorkSheet(spreadsheet, title: 'Settings');

      final cellValue = await _userSheet!.values.row(1, fromColumn: 1);

      final activeTab = cellValue.isNotEmpty ? cellValue[0] : null;

      if (activeTab != null) {
        _activeTab = activeTab as String;
        _initializeUserSheet();
        print('Active Tab: $_activeTab');
      }
    } catch (e) {
      print('Init Error: $e');
    }
  }

  static Future<String> getActiveTab() async {
    final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    final temp = await _getWorkSheet(spreadsheet, title: 'Settings');
    final cellValue = await temp!.values.row(1, fromColumn: 1);

    if (cellValue.isNotEmpty) {
      return _activeTab = cellValue[0] as String;
    }
    return '';
  }

  static Future<bool> updateTab(String tabName) async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      _userSheet = await _getWorkSheet(spreadsheet, title: 'Settings');

      await _userSheet!.values.insertValue(tabName, column: 1, row: 1);
      init();
      print('Active Tab: $activeTab');
      return true;
    } catch (e) {
      print('Update Error: $e');
      return false;
    }
  }

  static Future<List<String>> getAllWorksheetTitles() async {
    try {
      final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
      return spreadsheet.sheets.map((sheet) => sheet.title).toList();
    } catch (e) {
      print('Error fetching worksheet titles: $e');
      return [];
    }
  }

  static Future<Worksheet?> _getWorkSheet(
    Spreadsheet spreadsheet, {
    required String title,
  }) async {
    try {
      var worksheet = spreadsheet.worksheetByTitle(title);
      worksheet ??= await spreadsheet.addWorksheet(title);
      return worksheet;
    } catch (e) {
      print("Worksheet Error: $e");
      return null;
    }
  }

  static Future<List<User>> getAll() async {
    if (_userSheet == null) return [];
    final data = await _userSheet!.values.map.allRows();
    return data == null ? [] : data.map(User.fromjson).toList();
  }

  static Future<User?> getById(int id) async {
    if (_userSheet == null) return null;
    final json = await _userSheet!.values.map.rowByKey(id, fromColumn: 1);
    return json == null ? null : User.fromjson(json);
  }

  static Future insert(List<Map<String, dynamic>> rowList) async {
    if (_userSheet == null) return;
    _userSheet!.values.map.appendRows(rowList);
  }

  static Future<int> getRowCount() async {
    if (_userSheet == null) return 0;
    final lastRow = await _userSheet!.values.lastRow();
    return lastRow == null ? 0 : int.tryParse(lastRow.first) ?? 0;
  }

  static Future<bool> update(int id, Map<String, dynamic> data) async {
    if (_userSheet == null) return false;
    return _userSheet!.values.map.insertRowByKey(id, data);
  }

  static Future<bool> updateCell(
      {required int id, required String key, required dynamic value}) async {
    if (_userSheet == null) return false;
    return _userSheet!.values
        .insertValueByKeys(value, columnKey: key, rowKey: id);
  }

  static Future<bool> deleteById(int id) async {
    if (_userSheet == null) return false;
    final index = await _userSheet!.values.rowIndexOf(id);
    if (index == -1) return false;
    return _userSheet!.deleteRow(index);
  }

  static Future<Map<String, double>> getPieChartData() async {
  List<User> users = await getAll(); 
  print('Fetched users: $users'); 
  Map<String, double> pieChartData = {};

  for (var user in users) {
    // Only include entries where Type is "Expense"
    if (user.type == "Expense") {
      String category = user.category ?? 'Unknown'; 
      double total = user.total?.toDouble() ?? 0.0; 

      if (pieChartData.containsKey(category)) {
        pieChartData[category] = pieChartData[category]! + total;
      } else {
        pieChartData[category] = total;
      }
    }
  }
  return pieChartData; 
}


  static Future<String> getTotal() async {
  final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
  final temp = await _getWorkSheet(spreadsheet, title: _activeTab);
  final cellValue = await temp!.values.row(1, fromColumn: 9);

  if (cellValue.isNotEmpty) {
    return cellValue[0].toString(); // Return as string
  }
  return '0'; // Ensure it returns a valid value, even if empty
}

}
