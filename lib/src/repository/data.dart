// like "API" between ui and db
import 'package:logger/logger.dart';
import 'package:stdetector/src/repository/files.dart';
import 'package:stdetector/src/repository/record_controller.dart';
import 'package:stdetector/utils/pair.dart';

import '../model/record.dart';

class Data {
  final Files _files = Files();
  final RecordController _recordController = RecordController();
  final logger = Logger();

  ///CRUDs

  Future<Record> insertNewRecord(Record record) async {
    Record r = await _recordController.insert(record);
    return r;
  }

  Future<int> removeRecord(Record record) async {
    // remove row on db
    int r = await _recordController.delete(record);
    // remove file on dist
    try {
      _files.delete(record: record);
    } catch (error, stacktrace) {
      logger.e(error, stackTrace: stacktrace);
    }
    return r;
  }

  Future<int> updateTask(Pair<Record, Record> p) async {
    //update on db
    int r = await _recordController.update(p.newer);
    //update on disk
    try {
      _files.updateFileName(pairRecords: p);
    } catch (error, stacktrace) {
      logger.e(error, stackTrace: stacktrace);
    }

    return r;
  }

  Future<Map<int, Record>> getMapRecord() async {
    List<Record> record = await _recordController.getList();

    Map<int, Record> recordsMap = <int, Record>{};
    for (var p in record) {
      recordsMap[p.id] = p;
    }
    return recordsMap;
  }
}
