import 'package:gsheets/gsheets.dart';
import 'package:mon/model/user.dart';

class DataApi {
  static String _activeTab = 'Data';
  static String? activeTab;
  static const _credetials = r'''
{
  "type": "service_account",
  "project_id": "gsheets-439912",
  "private_key_id": "113e1822e91247c27d989eeaa9000eecb80c16da",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDdSCTx5KHqiPGo\nxXt6R2gw6M3lonF6HLOcygM8Q3NDWxKvVNe0L5/iQ32yLUOI3QdX9tjAJBkk6RHt\n1XOzt4/s6Fk+9O5haku9DbC1mA/R9JWrCmddEJPmv7eSMQNNcEVo7GFBhbC6l5UE\nqkRYKH8vfgmC9e/hsibkWWiX7Xwgoi1uwMwc3hkbpBx1I/hXMnvGSSBhLsa5+3bb\nMAXSz0gcELrqjuLQk7i3yaowh7+kZu7lOg/iB77C7x8mqgsY3wl8ti5w/XrmvLDD\ndzpGTIdeSsZoksgN39Ckh6S5Vysm2NAV0Pl5SorlutfwVX8OT++rAGEWQrFt8NUQ\nqEOR6EizAgMBAAECggEAJ2xfCKmPH1XemA72/MYUDgKsDClwxiyu41QqV2Y89tcW\n8R3QgE2r0ofrsP7XdV7LnCRiYXkM8cKEazcIMhCWF8Mdg1Xn0ns5mykBPpkk2GcW\n8y4bVD1L3GRztBv/VqCV/Sd//EhxQA0Zg4dCPeKZJkDyON7QKgmvXCeBtu+cmcN2\nIuZUbSK6oLp0ZYkzC5tM18DXsy7bGNo8ANTGEgzzUYVE+SSjLy7qM3n7Ydn8Um23\nGUZRqmnF6TF6S7b13TT9SrRvKDL73tnt10fBYo+TnsnG4HqokXvWQ1cRTEGBxKJ9\nxQxSTKw75Qtcw4Ej6zgKmevLuiPoLul1dZZz7ezl4QKBgQD6KeGhTKtfUQwj/8Gn\n4g+2iNx8m04HYiPXIjERxYguQ16AOAESzqTn0parB86gW6TPgK/m5wZMxll/x4hp\nhp1n+CnYhNM5szIsJuTqiJCVaKPp9Xj/fXGvcZXSqCNsyvftuiB5+whTqPnh+ZfF\nmORXnJ0YxyJJcqdnBuD+1WYrvQKBgQDiccO7RNv+j6J4U8JsENeDTzDW5vkUEabu\nUs6Q+ad0Y0BWnwyIn2X4vzh1jzdG1BIpD+B7Om0MMCqM7Z5OxxPiP31MQvE/UcIx\ncb0B5jsm4Rlcy3hNbbENIiocXXDTtgeYb6O1O3ZitYjhSoqx6JKrOEGoH8ajB8rH\n8/FU8+rVLwKBgQCmU+5Wxpky2LpPvR7PNrjnznt6xe/NbO0TfwJNJJ7004ojihj8\nnjR6hkPzF0/EwuoDpTZPOc+wgDjFgq8qKnzBwfhgo3+lX4W+YWXWolIvZNGHHtUC\nWi+aTNUmqPBUx2aswxIQyF2y8iiinMbSdGNt9Q1mihA78WVoVOSHyu8RqQKBgQCs\nwBePbTfb2x4aZ+Ph53NSZH6g4/JPQiw0ko2uAhei7fjuXEYGkHwNqWvcG5cS/MSh\n+M/LksYQT0qW2swz0yIzLzZakJNVN/1LFTcZFNg5j+52YW90umMg3th7bTme+baP\nr1OX9jYZld5H6UMn+IK0BqXoKd2zEEW+BzcsFS0o1wKBgQDfLvbN4zmbi9X7q1Gb\nL0U7Y7XEGGrVdBotcw4wZ2Qk3u8/gAhftVDh8yqNyS5c2ieJqOCt3/ripMKpYwH8\nFsm0QQ/GNfLQgQJY0IzwxhiBBik48LPQJX09y/L0wQARAS0fAlLfWnVjsdloiWsH\n1SHOvX2fNMtr+WMEl3FHizRf7g==\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@gsheets-439912.iam.gserviceaccount.com",
  "client_id": "103206252714704298026",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gsheets-439912.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';
  static final _spreadsheetId = "1QrpvIyA5MysnZPoJjkYc98vx_pqAklzsdB1gwEv1YMk";
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
    List<User> users = await getAll(); // Fetch all users
    print('Fetched users: $users'); // Debugging line
    Map<String, double> pieChartData = {};

    for (var user in users) {
      String category =
          user.category ?? 'Unknown'; // Default to 'Unknown' if null
      double total = user.total?.toDouble() ?? 0.0; // Default to 0.0 if null

      // Accumulate the totals by category
      if (pieChartData.containsKey(category)) {
        pieChartData[category] = pieChartData[category]! + total;
      } else {
        pieChartData[category] = total;
      }
    }

    return pieChartData; // Return the map of category totals
  }

  static Future<String> getTotal() async {
    final spreadsheet = await _gsheets.spreadsheet(_spreadsheetId);
    final temp = await _getWorkSheet(spreadsheet, title: _activeTab);
    final cellValue = await temp!.values.row(1, fromColumn: 9);

    if (cellValue.isNotEmpty) {
      return _activeTab = cellValue[0] as String;
    }
    return '';
  }
}
