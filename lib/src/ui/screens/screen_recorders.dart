import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stdetector/utils/pair.dart';

import '../../bloc/record_bloc.dart';
import '../../model/record.dart';
import '../../repository/files.dart';
import '../widgets/widget_record.dart';

class ScreenRecorders extends StatefulWidget {
  const ScreenRecorders({super.key});

  @override
  State<ScreenRecorders> createState() {
    return _ScreenRecorders();
  }
}

class _ScreenRecorders extends State<ScreenRecorders> {
  final RecordBloc _recordBloc = RecordBloc();
  bool isEditing = false;
  final Map<dynamic, Record> _selectedRecords = {};

  @override
  void initState() {
    super.initState();
    //_taskBloc.readTasks.add(widget.project);
  }

  @override
  void dispose() {
    super.dispose();
    _recordBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Records"),
        actions: [options(context)],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: Container(
          ///padding: EdgeInsets.only(bottom: 80),
          ///margin: EdgeInsets.only(bottom: 80),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: StreamBuilder<Map<int, Record>>(
            stream: _recordBloc.recordListStream,
            builder: (BuildContext context,
                AsyncSnapshot<Map<int, Record>> snapshot) {
              List<Record> taskList =
                  snapshot.hasData ? mapToList(snapshot.data!) : [];
              return ListView.builder(
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  if (index == (taskList.length - 1)) {
                    return Column(
                      children: [
                        WidgetRecord(
                          record: taskList[index],
                          onSelected: onSelected,
                          onUnselected: onUnselected,
                          onTouch: () {},
                          editing: isEditing,
                        ),
                        Container(
                          height: 100,
                        )
                      ],
                    );
                  } else {
                    return WidgetRecord(
                      record: taskList[index],
                      onSelected: onSelected,
                      onUnselected: onUnselected,
                      onTouch: () {},
                      editing: isEditing,
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
      //floatingActionButton: options(context),
    );
  }

  Widget options(BuildContext context) {
    if (isEditing) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _selectedRecords.length < 2
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showDialogUpdate(context);
                },
              )
            : const SizedBox(width: 2.0),
        const SizedBox(
          height: 15,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            _showDialogDelete(context);
          },
        ),
        const SizedBox(
          height: 15,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            _shareFiles();
          },
        ),
      ]);
    } else {
      return const SizedBox(width: 2.0);
    }
  }

  void _showDialogDelete(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            //title: Text(' '),
            content: const Text("Delete selected records"),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("cancel")),
              TextButton(
                onPressed: () {
                  _selectedRecords.forEach((k, r) {
                    _recordBloc.removeRecord.add(r);

                    //_taskBloc.removeTask.add(v); //remove on db
                    //widget.updateCard(); //update parent
                  });
                  //widget.updateCard(); //update parent
                  setState(() {
                    _selectedRecords.clear();
                    isEditing = false;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("delete"),
              )
            ],
          );
        });
  }

  void _showDialogUpdate(BuildContext context) {
    late Record tempRecord;
    _selectedRecords.forEach((k, v) {
      tempRecord = v;
    });
    Record oldRecord = Record(
        id: tempRecord.id,
        filename: tempRecord.filename,
        samples: tempRecord.samples,
        date: tempRecord.date);
    String filename = tempRecord.filename
        .substring(0, (tempRecord.filename.length - 4)); // remove .csv

    final controllerEn = TextEditingController(text: filename);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            title: const Text("Update"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextField(
                      controller: controllerEn,
                      onChanged: (value) {
                        filename = value;
                      },
                      decoration: const InputDecoration(labelText: "filename"),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Save"),
                onPressed: () {
                  tempRecord.filename = "$filename.csv";
                  _recordBloc.updateRecord.add(Pair<Record, Record>(
                      older: oldRecord, newer: tempRecord));
                  setState(() {
                    _selectedRecords.clear();
                    isEditing = false;
                  });
                  //widget.updateCard();
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  /// convert map to list
  List<Record> mapToList(Map<dynamic, Record> mapTasks) {
    List<Record> recordList = [];
    List<Record> temp = [];
    mapTasks.forEach((key, value) {
      recordList.add(value);
    });
    //read inverse, the uncompleted tasks at the end
    int numTasks = recordList.length;
    for (int i = (numTasks - 1); i >= 0; i--) {
      temp.add(recordList[i]);
    }

    return temp;
  }

  /// Action on select record
  void onSelected(Record record) {
    setState(() {
      _selectedRecords[record.id] = record;
      isEditing = true;
    });
  }

  /// Action on unselect record
  void onUnselected(Record record) {
    setState(() {
      _selectedRecords.remove(record.id);
    });
    if (_selectedRecords.isEmpty) {
      setState(() {
        isEditing = false;
      });
    }
  }

  /// share files
  void _shareFiles() async {
    Files files = Files();
    List<String> pathFiles = [];
    List<XFile> pathXFiles = [];
    for (Record r in _selectedRecords.values) {
      File file = await files.getLocalFile(r);
      pathFiles.add(file.path);
      pathXFiles.add(XFile(file.path));
    }

    Share.shareXFiles(pathXFiles);
    await Share.shareXFiles(pathXFiles);
  }
}
