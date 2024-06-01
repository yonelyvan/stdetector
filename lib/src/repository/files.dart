import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stdetector/utils/pair.dart';

import '../model/record.dart';

class Files {
  /// CRUD files
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> getLocalFile(Record record) async {
    final path = await _localPath;
    return File('$path/${record.filename}');
  }

  /// Create
  Future<File> writeSignal(
      {required List<int> signal, required Record record}) async {
    String str = getDataGSR(signal);
    final file = await getLocalFile(record);
    return file.writeAsString(str);
  }

  Future<File> writeSignalAndStressLevels(
      {required List<List<int>> signalAndStressLevels,
      required Record record}) async {
    String str = getDataGSRAndStressLevels(signalAndStressLevels);
    final file = await getLocalFile(record);
    return file.writeAsString(str);
  }

  /// Update
  Future<void> updateFileName(
      {required Pair<Record, Record> pairRecords}) async {
    final file = await getLocalFile(pairRecords.older);

    final path = await _localPath;
    String newPath = '$path/${pairRecords.newer.filename}';
    await file.rename(newPath);
  }

  // Delete
  Future<void> delete({required Record record}) async {
    final file = await getLocalFile(record);
    await file.delete(recursive: false);
  }

  /// CSV files
  // input: GSR values: [x1, x2, ..., xn]
  // output: csv format with GSR data
  String getDataGSR(List<int> signal) {
    List<List<dynamic>> rows = [];
    for (int e in signal) {
      List<dynamic> d = [];
      d.add(e);
      rows.add(d);
    }
    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }

  // input: GSR values: [[x1,l1], [x2,l2], ..., [xn,ln]]
  // output: csv format with GSR data
  String getDataGSRAndStressLevels(List<List<int>> signalAndStressLevels) {
    List<List<dynamic>> rows = [];
    for (List<int> e in signalAndStressLevels) {
      //List<dynamic> d = [];
      //d.add(e);
      rows.add(e);
    }
    String csv = const ListToCsvConverter().convert(rows);
    return csv;
  }
}
