import 'dart:async';

import 'package:stdetector/utils/pair.dart';

import '../model/record.dart';
import '../model/status_tab_bar.dart';
import '../repository/data.dart';

class RecordBloc {
  final Data data = Data();
  Map<int, Record> _recordMapList = {};
  StatusMenuTab _statusMenuTab = StatusMenuTab.none;

  /// stream controller CRUD
  final _recordListStreamController = StreamController<Map<int, Record>>();

  final _addRecordStreamController = StreamController<Record>();

  final _updateRecordStreamController =
      StreamController<Pair<Record, Record>>();
  final _removeRecordStreamController = StreamController<Record>();

  //for status tab_bar
  final _statusBarStreamController = StreamController<StatusMenuTab>();
  final _changeStatusTabBarStreamController = StreamController<StatusMenuTab>();

  /// getters : Stream & sinks
  Stream<Map<int, Record>> get recordListStream =>
      _recordListStreamController.stream;

  StreamSink<Map<int, Record>> get recordListSink =>
      _recordListStreamController.sink;

  StreamSink<Record> get addRecord => _addRecordStreamController.sink;

  StreamSink<Pair<Record, Record>> get updateRecord =>
      _updateRecordStreamController.sink;

  StreamSink<Record> get removeRecord => _removeRecordStreamController.sink;

  //for status tab_bar
  Stream<StatusMenuTab> get statusBarStream =>
      _statusBarStreamController.stream; //for ui
  StreamSink<StatusMenuTab> get statusBarSink =>
      _statusBarStreamController.sink; //for ui

  StreamSink<StatusMenuTab> get changeStatusTabBar =>
      _changeStatusTabBarStreamController.sink;

  /// construct set listeners for changes
  RecordBloc() {
    //push data
    recordListSink.add(_recordMapList);
    _readRecord();
    //push status tab init
    _statusBarStreamController.add(_statusMenuTab);

    //listen for changes
    _addRecordStreamController.stream.listen(_addRecord);
    //_readTasksStreamController.stream.listen(_readRecord);
    _updateRecordStreamController.stream.listen(_updateRecord);
    _removeRecordStreamController.stream.listen(_removeRecord);
    //for status tab bar
    _changeStatusTabBarStreamController.stream.listen(_changeStatus);
  }

  /// call functions
  _addRecord(Record record) {
    data.insertNewRecord(record).then((r) {
      _recordMapList[r.id] = r;
      recordListSink.add(_recordMapList);
    });
  }

  _readRecord() {
    data.getMapRecord().then((projects) {
      _recordMapList = projects;
      _recordListStreamController.add(_recordMapList);
    });
  }

  _updateRecord(Pair<Record, Record> p) {
    data.updateTask(p).then((value) {
      if (value >= 1) {
        _recordMapList[p.older.id] = p.newer;
        recordListSink.add(_recordMapList);
      }
    });
  }

  _removeRecord(Record record) {
    data.removeRecord(record).then((value) {
      if (value >= 1) {
        _recordMapList.remove(record.id);
        recordListSink.add(_recordMapList);
      }
    });
  }

  //for status tab bar
  _changeStatus(StatusMenuTab newStatus) {
    _statusMenuTab = newStatus;

    _statusBarStreamController.add(_statusMenuTab);
  }

  ///dispose *
  void dispose() {
    _recordListStreamController.close();
    _addRecordStreamController.close();

    _updateRecordStreamController.close();
    _removeRecordStreamController.close();

    _statusBarStreamController.close();
    _changeStatusTabBarStreamController.close();
  }
}
