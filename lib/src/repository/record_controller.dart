import 'dart:async';

import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

import '../model/record.dart';

///CRUD acciones sobre la base de datos
class RecordController {
  static const String dbFileName = "records01.db"; // test

  static final RecordController _instance = RecordController._internal();

  factory RecordController() => _instance;

  RecordController._internal();

  /// Logger for debugging
  final logger = Logger();

  static Future<Database> _openDB() async {
    String databasesPath = await getDatabasesPath();
    String path = "$databasesPath/$dbFileName";
    return openDatabase(path, version: 1, onCreate: (database, version) {
      Record(date: DateTime.now()).createTable(database);
    });
  }

  ///CRUD
  ///select
  Future<List<Record>> getList() async {
    Database? dbClient = await _openDB();
    try {
      List<Map> maps = await dbClient.query(Record.tableName,
          columns: ["_id", "filename", "samples", "date"]);
      List<Record> r = maps.map((i) => Record.fromMap(i)).toList();
      return r; //lista de objetos
    } catch (error, stacktrace) {
      logger.e(error, stackTrace: stacktrace);
    }
    return [];
  }

  ///insert
  Future<Record> insert(Record record) async {
    var dbClient = await _openDB();
    record.id = await dbClient.insert(
      Record.tableName,
      record.toMap(),
    );
    return record;
  }

  ///delete
  Future<int> delete(Record element) async {
    var dbClient = await _openDB();
    return await dbClient
        .delete(Record.tableName, where: '_id = ?', whereArgs: [element.id]);
  }

  ///update
  Future<int> update(Record element) async {
    var dbClient = await _openDB();

    return await dbClient.update(Record.tableName, element.toMap(),
        where: '_id = ?', whereArgs: [element.id]);
  }
}
