import 'package:gsheets/gsheets.dart';
import 'package:mon/api/sheets/config.dart';
import 'package:mon/model/user.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DataApi {
  static String _activeTab = 'Data';
  static String? activeTab;
  static const _credetials = Config.credentials;
  static const _spreadsheetId = Config.spreadsheetId;
  static final _gsheets = GSheets(_credetials);
  static Worksheet? _userSheet;
  static Spreadsheet? _cachedSpreadsheet;
  static List<String>? _cachedHeaders;

  static Future<void> setActiveTab(String tabName) async {
    _activeTab = tabName;
    await _initializeUserSheet();
  }

  static Future<Spreadsheet> _getSpreadsheet() async {
    if (_cachedSpreadsheet != null) return _cachedSpreadsheet!;
    _cachedSpreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    return _cachedSpreadsheet!;
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
      final spreadsheet = await _getSpreadsheet();

      final settingsSheet = await _getWorkSheet(spreadsheet, title: 'Settings');
      final cellValue = await settingsSheet!.values.row(1, fromColumn: 1);

      final activeTabName = cellValue.isNotEmpty ? cellValue[0] : 'Data';
      _activeTab = activeTabName;

      _userSheet = await _getWorkSheet(spreadsheet, title: _activeTab);

      print('[Init] Active Tab set to: $_activeTab');

      _cachedHeaders = await _userSheet!.values.row(1);
      if (_cachedHeaders == null ||
          _cachedHeaders!.isEmpty ||
          _cachedHeaders!.first != UserFields.id) {
        _cachedHeaders = UserFields.getFields();
        await _userSheet!.values.insertRows(1, [_cachedHeaders!]);
      }
    } catch (e) {
      print('[Init Error]: $e');
    }
  }

  static Future<String> getActiveTab() async {
    final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    final temp = await _getWorkSheet(spreadsheet, title: 'Settings');
    final cellValue = await temp!.values.row(1, fromColumn: 1);

    if (cellValue.isNotEmpty) {
      return _activeTab = cellValue[0];
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

  static Future<bool> insert(List<Map<String, dynamic>> rowList) async {
    final connectivity = await Connectivity().checkConnectivity();
    print('[Insert] Connectivity: $connectivity');

    if (connectivity == ConnectivityResult.none) {
      print('[Insert] No internet. Saving offline...');
      final box = Hive.box('offline_data');

      for (var row in rowList) {
        final cleanRow = Map<String, dynamic>.from(row)..remove('id');
        print('[Insert] Saving row offline: $cleanRow');
        box.add(cleanRow);
      }

      return true;
    }

    await init();
    if (_userSheet == null) {
      print('[Insert] userSheet is still null after init. Aborting insert.');
      return false;
    }

    final currentHeaders = await _userSheet!.values.row(1);
    if (currentHeaders.isEmpty || currentHeaders[0] != UserFields.id) {
      final headers = UserFields.getFields();
      await _userSheet!.values.insertRows(1, [headers]);
    }

    print('[Insert] Appending to $_activeTab: $rowList');
    final mainInsert = _userSheet!.values.map.appendRows(rowList);

    final name = rowList.first[UserFields.name]?.toString().toLowerCase();
    Future<void>? mtgInsert;

    if (name == 'mtg') {
      mtgInsert = () async {
        try {
          final spreadsheet = await _getSpreadsheet();
          Worksheet? dataSheet = spreadsheet.worksheetByTitle('Data');
          dataSheet ??= await spreadsheet.addWorksheet('Data');

          final dataHeaders = await dataSheet.values.row(1);
          if (dataHeaders.isEmpty || dataHeaders[0] != UserFields.id) {
            final headers = UserFields.getFields();
            await dataSheet.values.insertRows(1, [headers]);
          }

          print('[Insert] Also appending to Data sheet: $rowList');
          await dataSheet.values.map.appendRows(rowList);
        } catch (e) {
          print('[Insert] Error writing to Data sheet: $e');
        }
      }();
    }

    // Run both in parallel (or just the main if not MTG)
    await Future.wait([
      mainInsert,
      if (mtgInsert != null) mtgInsert,
    ]);

    await syncOfflineData();
    return true;
  }

  static Future<void> syncOfflineData() async {
    print('[Sync] Checking offline data...');
    final box = Hive.box('offline_data');

    if (box.isEmpty) {
      print('[Sync] No offline data found.');
      return;
    }

    final offlineRows = box.values.map<Map<String, dynamic>>((e) {
      return Map<String, dynamic>.from(e as Map);
    }).toList();

    print('[Sync] Found ${offlineRows.length} offline rows to sync.');
    for (var row in offlineRows) {
      print('[Sync] Offline row: $row');
    }

    try {
      await init(); // ✅ Ensure _userSheet points to correct active tab

      if (_userSheet == null) {
        print('[Sync] Still null after init. Aborting sync.');
        return;
      }

      final headers = _cachedHeaders!;
      print('[Sync] Current headers in sheet: $headers');

      if (headers.isEmpty || headers[0] != UserFields.id) {
        final newHeaders = UserFields.getFields();
        print('[Sync] Inserting headers: $newHeaders');
        await _userSheet!.values.insertRows(1, [newHeaders]);
      }

      int nextId = await getRowCount() + 1;
      final normalizedRows = offlineRows.map((row) {
        final newRow = <String, dynamic>{};
        for (final header in headers) {
          if (header == UserFields.id) {
            newRow[UserFields.id] = nextId++;
          } else {
            final match = row.entries.firstWhere(
              (entry) => entry.key.toLowerCase() == header.toLowerCase(),
              orElse: () => const MapEntry('', null),
            );
            newRow[header] = match.value;
          }
        }
        return newRow;
      }).toList();

      print('[Sync] Final normalized rows to insert:');
      for (var row in normalizedRows) {
        print('[Sync] => $row');
      }

      final appendResult =
          await _userSheet!.values.map.appendRows(normalizedRows);
      print('[Sync] appendRows result: $appendResult');

      if (appendResult == true) {
        await box.clear();
        print('[Sync] ✅ Sync successful. Offline data cleared.');
      } else {
        print('[Sync] ❌ appendRows returned false. Data not inserted.');
      }
    } catch (e, stacktrace) {
      print('[Sync] ❌ Exception during sync: $e');
      print('[Sync] Stacktrace:\n$stacktrace');
    }
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
        double total = user.total.toDouble() ?? 0.0;

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
